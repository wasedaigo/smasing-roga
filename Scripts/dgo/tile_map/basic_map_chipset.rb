require "dgo/tile_map/map_chipset"

module DGO
  module TileMap
    class BasicMapChipset < MapChipset
      def initialize(filename, grid_width, grid_height)
        super(filename, grid_width, grid_height)
        @type = :base
        
        @palet_chips = Array.new(self.x_count * self.y_count) do |i|
          PaletChip.new(self, i, self.x_count, CollisionType::NONE, 0)
        end
      end
    end
  end
end
