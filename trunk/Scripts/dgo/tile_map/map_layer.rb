require "dgo/tile_map/palet_chip"
module DGO
  module TileMap
    class MapLayer
      attr_reader :map_data, :map_chipset_no_data, :texture

      def initialize(map, map_data)
        @map = map
        @map_data = map_data
        @blend_mode = :alpha
      end

      def width
        @map.grid_width * @map_data.width
      end

      def height
        @map.grid_height * @map_data.height
      end

      def set_size(x_count, y_count)
        @map_data.set_size(x_count, y_count)
        @map_data.map! do |value|
          if value
            value
          else
            MapChip.new(PaletChip.generate_empty_paletchip(false), 0, 0)
          end
        end
      end

      def render_data_layer(texture, rx, ry, sx, sy, w, h)
        self.update_complementary_data(rx, ry, sx, sy, w, h)
        (0..([sx + w, @map_data.width].min - sx - 1)).each do |x|
          (0..([sy + h, @map_data.height].min - sy - 1)).each do |y|
            map_chip = @map_data[sx + x, sy + y]
            
            next if map_chip.nil?
            next if map_chip.palet_chip.no == 0
            unless(map_chip.palet_chip.chipset.nil?)
              map_chip.palet_chip.render(texture, rx + x, ry + y, @blend_mode, 0, 0, map_chip.sub1, map_chip.sub2, @map.frame_no)
            end
          end
        end
      end

      def render(textures, rx, ry, sx, sy, w, h)
        self.update_complementary_data(rx, ry, sx, sy, w, h)
        (0..([sx + w, @map_data.width].min - sx - 1)).each do |x|
          (0..([sy + h, @map_data.height].min - sy - 1)).each do |y|
            map_chip = @map_data[sx + x, sy + y]
            next if map_chip.nil?
            next if map_chip.palet_chip.no == 0
            unless(map_chip.palet_chip.chipset.nil?)
              map_chip.palet_chip.render(textures[map_chip.palet_chip.priority], rx + x, ry + y, @blend_mode, 0, 0, map_chip.sub1, map_chip.sub2, @map.frame_no)
            end
          end
        end
      end

      def update_complementary_data(rx, ry, sx, sy, w, h)
        # set complementary values
        (0..([sx + w, @map_data.width].min - sx - 1)).each do |x|
          (0..([sy + h, @map_data.height].min - sy - 1)).each do |y|
            map_chip = @map_data[sx + x, sy + y]
            next unless map_chip
            map_chip.sub1, map_chip.sub2 = map_chip.palet_chip.get_subs(sx + x, sy + y, @map_data)
          end
        end
      end
    end
  end
end