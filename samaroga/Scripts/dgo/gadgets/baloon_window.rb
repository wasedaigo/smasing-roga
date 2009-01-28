require  "dgo/gadgets/window"

module DGO
  module Gadgets
    class BaloonWindow

      attr_reader :x
      attr_reader :y

      attr_accessor :visible
      def initialize(target_x, target_y, width, height, texture, grid_size, options = {})
        @x = 0
        @y = 0
        @arrow_x = 0
        @arrow_dir_x = -1
        @arrow_dir_y = -1
        @visible = true
        @options = options
        @texture = texture
        @window = Window.new(0, 0, [width, 48].max, height, @texture, grid_size)
        self.update(target_x, target_y, SCREEN_WIDTH, SCREEN_HEIGHT)
      end

      def content_texture
        return @window.content_texture
      end

      def frame_texture
        return @window.frame_texture
      end

      def height
        return @window.frame_texture.height
      end

      def width
        return @window.frame_texture.width
      end

      def update(target_x, target_y, show_width, show_height)
        tx = target_x - self.width / 2
        t = tx
        ty = target_y - self.height + 4

        if target_x >= 0
          tx = 0 if tx < 0
        else
          tx = target_x
        end
        
        if target_x <= show_width
          tx = show_width - self.width if tx + self.width > show_width
        else
          tx = target_x
        end

        @arrow_x = t - tx + self.width / 2 + @window.grid_size
        @arrow_x = 0 if @arrow_x < 0
        @arrow_x = self.width - @window.grid_size * 2 if @arrow_x > self.width - @window.grid_size * 2 

        case @options[:x_fixed]
        when :left
          @arrow_dir_x = -1
        when :right
          @arrow_dir_x = 1
        else
          if target_x > show_width / 2
            @arrow_dir_x = 1
          else
            @arrow_dir_x = -1
          end
        end

        @arrow_dir_y = 1
        ty -= 6
        case @options[:y_fixed]
        when :up
          @arrow_dir_y = -1
        when :down
          @arrow_dir_y = 1
        else
          if ty + height > show_height
            @arrow_dir_y = 1
          end
          if ty < 0
            ty = target_y + 16
            @arrow_dir_y = -1
          end
        end

        @x = tx
        @y = ty
      end

      def render(s, x = 0, y = 0)
        return unless @visible
    
        @window.render(s, x + @x, y + @y)

        if @arrow_dir_y == -1
          s.render_texture(@texture, x + @x + @arrow_x - @window.grid_size * (@arrow_dir_x) - 8, y + @y - @window.grid_size + 3,
                           :src_x=>(2 + (1 + @arrow_dir_x)/2) * @window.grid_size ,:src_y => 0, :src_width => @window.grid_size, :src_height => @window.grid_size)
        end
        if @arrow_dir_y == 1
          s.render_texture(@texture, x + @x + @arrow_x - @window.grid_size * (@arrow_dir_x) - 8, y + @y + height - 3,
                           :src_x=>(2 + (1 + @arrow_dir_x)/2) * @window.grid_size ,:src_y => @window.grid_size, :src_width => @window.grid_size, :src_height => @window.grid_size)
        end

        s.render_texture(content_texture, x + @x + @window.grid_size / 2, y + @y + @window.grid_size / 2)
      end

    end
  end
end
