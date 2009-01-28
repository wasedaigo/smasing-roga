require "dgo/tile_map/collision_type"
require "dgo/tile_map/palet_chip"

module DGO
  module TileMap
    class MapChipset
      attr_reader  :grid_width, :grid_height, :texture, :palet_chips, :name, :type

      def initialize(filename, grid_width, grid_height)
        @grid_width = grid_width
        @grid_height = grid_height
        @name = File::basename(filename).split(".")[0]
        @texture = Texture.load(filename)
      end

      def width
        @texture.width
      end

      def height
        @texture.height
      end

      def x_count
        width / @grid_width
      end

      def y_count
        height / @grid_height
      end
      
      def sample_texture
        return @texture
      end

      # s?
      # def render(s, x, y, dx, dy, tx, ty, map_chipset_no, map_data)
        # map_data[tx, ty].render(x, y, dx, dy)
      # end

      def render_sample(s, x, y, options = {})
        s.render_texture(self.sample_texture, x, y, options)
      end
    end
  end
end
