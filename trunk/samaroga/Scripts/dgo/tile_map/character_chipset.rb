require "dgo/geometry/rectangle"

module DGO
  module TileMap
    class CharacterChipset
      include DGO::Geometry
      attr_reader :x, :y, :size_x, :size_y, :name
      attr_reader :animation_frame_number, :default_frame_no, :dir_number, :texture, :hit_rect
      #
      # * Initialize
      #     filename                          : Character Chip Set ID
      #     size_x                             : Chip width
      #     size_y                             : Chip height
      #     anime_frame_number   : Number of animation frames
      #     hit_rect                          : Hit area
      #
      def initialize(name, texture, size_x, size_y, animation_frame_number, dir_number)
        @name = name
        @size_x = size_x
        @size_y = size_y
        @animation_frame_number = animation_frame_number
        @default_frame_no = 1
        
        @dir_number = dir_number
        
        w = @size_x * @animation_frame_number
        h = @size_y * @dir_number
        
        if texture
          #if texture.width != w || texture.height != h
            #raise ('character chipset image size is wrong!')
          #end
          @texture = texture
        else
          @texture = Texture.new(w, h)
        end
      end
      #
      # * Width of chipset texture
      #
      def width
        @texture.width
      end
      #
      # * Height of chipset texture
      #
      def height
        @texture.height
      end
      #
      # * Chip count horizontally
      #
      def x_count
        width / @chip_size
      end
      #
      # * Chip count vertically
      #
      def y_ount
        height / @chip_size
      end
      #
      # * Render chip with direction and frame no
      #
      def render(s, x, y, sx, sy, frame_no, dir, options = {})
        options = {:src_x => (sx * animation_frame_number + frame_no) * size_x , :src_y => (sy * dir_number + dir) * size_y, :src_width => size_x, :src_height => size_y}.merge(options)
        s.render_texture(texture, x, y, options)
      end
    end
  end
end
