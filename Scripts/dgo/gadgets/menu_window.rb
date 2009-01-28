require  "dgo/gadgets/window"
require  "simple_input"

module DGO
  module Gadgets
    class MenuWindow

      attr_reader :index

      def initialize(x, y, width, height, commands, font, cursor_texture, window_frame_texture, colors = {})
        @index = 0
        @commands = commands
        @colors = colors
        @font = font
        @cursor_texture = cursor_texture
        @window = Window.new(x, y, width, height, window_frame_texture)
        self.refresh
      end

      def x
        return @window.x
      end

      def x=(value)
        @window.x = value
      end

      def y
        return @window.y
      end

      def y=(value)
        @window.y
      end

      def <<(obj)
        @commands << obj
      end

      def clear
        @index = 0
        @commands.clear
        content_texture.clear
      end

      def refresh
        @index = 0
        t = @window.content_texture
        t.clear
        @commands.each_with_index do |command, i|
          x = (0.5 * Window::GRID_SIZE).floor
          y = i * Window::GRID_SIZE + 2
          t.render_text(command, x + 1, y + 1, @font, Color.new(0, 0, 0, 128))
          t.render_text(command, x, y, @font, (@colors[i] || Color.new(255, 255, 255)))
        end
      end

      def update
        if SimpleInput.pressed_newly?(:space)
          Audio.play_se("res/Audio/Sound/ok")
          yield @index
        else
          t = 0
          t = 1 if SimpleInput.pressed_repeating? :down
          t = -1 if SimpleInput.pressed_repeating? :up
          t = [[@index + t, @commands.size - 1].min, 0].max
          Audio.play_se("res/Audio/Sound/cursor") if t != @index
          @index = t
        end
      end

      def render(s)
        @window.render(s)
        s.render_texture(@cursor_texture, self.x, self.y + (index + 0.5) * Window::GRID_SIZE + 2)
      end

    end
  end
end
