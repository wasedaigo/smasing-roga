require "dgo/tile_map/map_chipset"
require "dgo/tile_map/auto_palet_chip"
require "dgo/tile_map/anime_palet_chip"

module DGO
  module TileMap
    class AutoMapChipset < MapChipset
      attr_reader :frame, :x_count, :y_count
      def initialize(filename, grid_width, grid_height)
        @x_count = 1
        @y_count = 1
        super(filename, grid_width, grid_height)
        
        @anime = false
        @anime = (@texture.width == (12 * @grid_width)) && (@texture.height == (4 * @grid_height))
        raise(IndexError) unless (@anime || @texture.width == (3 * @grid_width) )

        @type = :auto

        @frame = 0
        @palet_chip = AutoPaletChip.new(self, CollisionType::NONE, 0)
        @max_frame = 4
      end
      
      def anime?
        return @anime
      end

      def next_frame
        @frame = (@frame + 1) % @max_frame
      end
      
      def palet_chips
        return [@palet_chip]
      end
      
      def render(s, x, y, dx, dy, tx, ty, map_chipset_no, map_data)
        map_data[tx, ty].render(x, y, dx, dy)
      end
    end
  end
end
