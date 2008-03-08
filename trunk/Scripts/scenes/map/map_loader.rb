require "scenes/map/collision_type"
require "scenes/map/palet_chip"
require "scenes/map/auto_map_chipset"
require "scenes/map/map_chipset"
require "scenes/map/map_chip"
require "scenes/map/config"
require "lib/table"

  module SRoga
  module MapLoader

    def self.load_normal_chipset
      return SRoga::MapChipset.new("ChipSet", SRoga::Config::GRID_SIZE)
    end
  
    def self.load_auto_chipset
      return SRoga::AutoMapChipset.new("ChipSet2", SRoga::Config::GRID_SIZE)
    end
  
    def self.load_map(chipsets)

      # load map chip counts(width & height)
      w_count = 80
      h_count = 80

      # load bottom layer
      t = Array.new(w_count * h_count)
      t.each_with_index do |obj, i|
        if(i % w_count == 0 || i % w_count == w_count - 1 || i / w_count == 0 || i / w_count == h_count - 1)
          t[i] = SRoga::MapChip.new(chipsets[0].palet_chips[1], 0, 0)
        else
          t[i] = SRoga::MapChip.new(chipsets[0].palet_chips[7], 0, 0)
        end
      end
      bottom_layer = DLib::Table.new(w_count, t)

      # load top layer
      t = Array.new(w_count * h_count)
      t.each_with_index do |obj, i|
        t[i] = SRoga::MapChip.new(chipsets[0].palet_chips[0], 0, 0)
      end

      top_layer = DLib::Table.new(w_count, t)

      # merge collision data
      t = Array.new(w_count * h_count)
      t.each_with_index do |obj, i|
        t[i] = CollisionType::NONE
      end
      collision_data = DLib::Table.new(w_count, t)

      # return results
      {:w_count=>w_count, :h_count=>h_count, :top_layer=>top_layer, :bottom_layer=>bottom_layer, :collision_data => collision_data}
    end
  end
end
