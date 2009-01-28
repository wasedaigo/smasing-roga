require "dgo/tile_map/map_chipset"
require "dgo/tile_map/auto_palet_chip"
require "dgo/tile_map/anime_palet_chip"

module DGO
  module TileMap
    class AnimeMapChipset < MapChipset
      attr_reader :textures
      def initialize(filename, grid_width, grid_height)
        super(filename + "_1", grid_width, grid_height)

        @name = File::basename(filename).split(".")[0]
        @textures = []
        @textures << self.texture
        @textures << Texture.load(filename + "_2")
        @textures << Texture.load(filename + "_3")
        @textures << Texture.load(filename + "_4")
        
        @type = :anime

        @palet_chips = Array.new(self.x_count * self.y_count) do |i|
          AnimePaletChip.new(self, i, self.x_count, CollisionType::NONE, 0)
        end
      end
    end
  end
end
