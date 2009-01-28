require "dgo/tile_map/collision_type"
require "dgo/tile_map/palet_chip"
require "dgo/tile_map/auto_map_chipset"
require "dgo/tile_map/basic_map_chipset"
require "dgo/tile_map/anime_map_chipset"
require "dgo/tile_map/map_chip"
require "dgo/table/table"
require "yaml"
require 'dgo/graphics/sprite'
      
module DGO
  module TileMap
    module MapLoader
      include DGO::TileMap
      include DGO::Graphics
      EMPTY_PALET_CHIP = PaletChip.generate_empty_paletchip(false)

      #
      # Generate blank map
      #
      def self.generate_blank_map(root_path, x_count, y_count, grid_width, grid_height, layer_no, base_chipset, anime_chipset)
        layers = []
        layer_no.times do
          t = Array.new(x_count * y_count)
          t.each_with_index {|model, i| t[i] = MapChip.new(EMPTY_PALET_CHIP, 0, 0) }
          layers << DGO::Table::Table.new(x_count, t)
        end

        # merge collision data
        t = Array.new(x_count * y_count)
        t.each_with_index do |model, i|
          t[i] = CollisionType::NONE
        end
        collision_data = DGO::Table::Table.new(x_count, t)

        # Load chipsets
        
        #panorama
        panorama = nil
        
        # base
        chipset_info = nil
        
        base_chipset = BasicMapChipset.new("#{root_path}/images/game/map/base/#{base_chipset}", grid_width, grid_height)

        str = "#{root_path}/data/chipsets/anime/#{anime_chipset}.yaml"
        if File.exist?(str)
          File.open(str, "r"){|f| chipset_info = YAML::load(f.read)}
          MapLoader.set_chipset_attributes(base_chipset, chipset_info)
        end
        
        # Anime
        anime_chipset = AnimeMapChipset.new("#{root_path}/images/game/map/anime/#{anime_chipset}", grid_width, grid_height)
        
        str = "#{root_path}/data/chipsets/anime/#{anime_chipset}.yaml"
        if File.exist?(str)
          chipset_info = nil
          File.open(str, "r") { |f| chipset_info = YAML::load(f.read) }
          MapLoader.set_chipset_attributes(anime_chipset, chipset_info)
        end

        # return results
        {:grid_width => grid_width, :grid_height => grid_height, :x_count=>x_count, :y_count=>y_count, :layers => layers, :collision_data => collision_data, :base_chipset => base_chipset, :anime_chipset => anime_chipset, :panorama => panorama}
      end

      #
      # add attributes to chips of the chipset
      #
      def self.set_chipset_attributes(chipset, info)
        return if info.nil?
        #p info
        chipset.palet_chips.each_with_index do |palet_chip, i|
          palet_chip.collision_type = info["collision"][i]
          palet_chip.priority = info["priority"][i]
        end
      end

      #
      # Load Panorama
      #
      def self.load_panorama(root_path, panorama_name)
        return nil unless panorama_name
        name = "game/panorama/" + panorama_name
        texture = Texture.load(root_path + "/images/" + name)
        return Sprite.new(texture, 0, 0, :texture_id => name)
      end
      
      #
      # Load three types of chipsets
      #
      def self.load_chipsets(root_path, model, grid_width, grid_height)
        chipsets = []
        auto_chipsets_info = nil
        model.each do |chipset|
          case chipset["type"]
            # Load auto chipsets
            when "auto"
              unless auto_chipsets_info
                File.open(root_path + "/data/chipsets/auto/setting.yaml", "r") do |f|
                  auto_chipsets_info = YAML::load(f.read)
                end
              end
 
              c = AutoMapChipset.new(root_path + "/images/game/map/auto/#{chipset["id"]}", grid_width, grid_height)
              MapLoader.set_chipset_attributes(c, auto_chipsets_info[chipset["id"]])
              chipsets << c
            when "base" : chipsets <<  self.load_base_chipset(root_path, chipset["id"], grid_width, grid_height)
            when "anime" : chipsets <<  self.load_anime_chipset(root_path, chipset["id"], grid_width, grid_height)
          end
        end
        return chipsets
      end

      def self.load_anime_chipset(root_path, id, grid_width, grid_height)
        chipset_info = nil
        fn = root_path + "/data/chipsets/anime/#{id}.yaml"
        File.open(fn, "r") { |f| chipset_info = YAML::load(f.read) } if File.exists?(fn)
        c = AnimeMapChipset.new(root_path + "/images/game/map/anime/#{id}", grid_width, grid_height)
        MapLoader.set_chipset_attributes(c, chipset_info)
        return c
      end
      
      def self.load_base_chipset(root_path, id, grid_width, grid_height)
        chipset_info = nil
        fn = root_path + "/data/chipsets/base/#{id}.yaml"
        File.open(fn, "r") { |f| chipset_info = YAML::load(f.read) } if File.exists?(fn)
        c = BasicMapChipset.new(root_path + "/images/game/map/base/#{id}", grid_width, grid_height)
        MapLoader.set_chipset_attributes(c, chipset_info)
        return c
      end

      #
      #
      #
      def self.load_editor_chipsets(root_path, model, grid_width, grid_height)
        
        chipset_info = nil
        File.open(root_path + "/data/chipsets/auto/setting.yaml", "r") {|f| chipset_info = YAML::load(f.read) }
        
        auto_chipsets = []
        Find.find(root_path + "/images/game/map/auto") do |path|
           Find.prune if path == root_path + "/images/game/map/auto/.svn" # ignore hidden files

          if File.file?(path)
            s = File::basename(path).split(".")[0]
            c = AutoMapChipset.new(root_path + "/images/game/map/auto/#{s}", grid_width, grid_height)
            MapLoader.set_chipset_attributes(c, chipset_info[s])
            auto_chipsets << c
          end
        end

        base_chipset = self.load_base_chipset(root_path, model["base"], grid_width, grid_height)
        anime_chipset = self.load_anime_chipset(root_path, model["anime"], grid_width, grid_height)
        
        return base_chipset, anime_chipset, auto_chipsets
      end
      
      #
      # Load collision data
      # layers: layers where you add collision data
      # x_count: tile count on x axis
      # y_count: tile count on y axis
      #
      def self.load_collisions(layers, x_count, y_count)
        # merge collision data
        collision_arr = Array.new(x_count * y_count) do
          CollisionType::NONE
        end

        layers.each do |layer|
          layer.each_with_index do |map_chip, i|
            palet_chip = map_chip.palet_chip
            if palet_chip.priority == 0
              collision_arr[i] = palet_chip.collision_type
            else
              collision_arr[i] |= palet_chip.collision_type
            end
          end
        end
        
        return Table::Table.new(x_count, collision_arr)
      end

      #
      # Load layer data
      # model: model
      # chipsets: chipset array
      # x_count: tile count on x axis
      # y_count: tile count on y axis
      #
      def self.load_layers(model, chipsets, x_count, y_count)
        layers = []
        model.each_with_index do |layer_data, layer_no|
          layer_arr = Array.new(x_count * y_count)
          i = 0
          layer_data.each_line do |line|
            arr = line.split(",")
            arr.each_with_index do |t, j|
              t.chomp!
              chip_data = t.split("-")
              if t.empty?
                layer_arr[i + j] = MapChip.new(EMPTY_PALET_CHIP, 0, 0)
              else
                layer_arr[i + j] = MapChip.new(chipsets[chip_data[0].to_i].palet_chips[chip_data[1].to_i], 0, 0)
              end
            end
            i += x_count
          end
          layers << Table::Table.new(x_count, layer_arr)
        end

        return layers
      end
      
      #
      #
      #
      def self.load_map(root_path, filename, editor = false)
        info = nil
        tiles = []
        layer_no = -1
        grid_width = 0
        grid_height = 0
        
        model = []
        
        # open up Yaml file and load
        File.open(root_path + "/" + filename, "r") do |f|
          model = YAML::load(f.read)
        end
        
        # get header map information
        grid_width = model["gw"].to_i
        grid_height = model["gh"].to_i
        x_count = model["x_count"].to_i
        y_count = model["y_count"].to_i

        # Only for editor mode
        if editor
          base_chipset, anime_chipset, auto_chipsets = MapLoader.load_editor_chipsets(root_path, model["editor"]["chipsets"], grid_width, grid_height)
        end

        panorama = MapLoader.load_panorama(root_path, model["panorama"])
        chipsets = MapLoader.load_chipsets(root_path, model["chipsets"], grid_width, grid_height)
        
        layers = MapLoader.load_layers(model["layers"], chipsets, x_count, y_count)
        collision_data = MapLoader.load_collisions(layers, x_count, y_count)

        # return results
        {
          :grid_width => grid_width, 
          :grid_height => grid_height, 
          :x_count => x_count, 
          :y_count => y_count, 
          :layers => layers, 
          :collision_data => collision_data,
          :base_chipset => base_chipset, 
          :anime_chipset => anime_chipset, 
          :auto_chipsets => auto_chipsets,
          :panorama => panorama
        }
      end
    end
  end
end
