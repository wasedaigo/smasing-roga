require  "dgo/gadgets/window"

module DGO
  module Gadgets
    class MessageWindow

      def initialize(x, y, width, height, font, window_frame_texture, messages = [],options = {})
        @messages = messages
        @window = Window.new(x, y, width, height, window_frame_texture)
        @font = font
        @options = options
        
        @messages.each_with_index do |message, i|
          @window.content_texture.render_shadow_text(message, (@window.content_texture.width - width) / 2, (@window.content_texture.height - height) / 2 + i * 16, font, Color.new(255, 255, 255), Color.new(0, 0, 0, 50))
        end
      end
      
      def alpha=(value)
        @options[:alpha] = value
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
      
      def text=(text)
        @text = text
      end

      def render(s)
        @window.render(s, 0, 0, @options)
      end

    end
  end
end
