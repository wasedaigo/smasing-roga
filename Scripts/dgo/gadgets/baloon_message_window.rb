require "dgo/gadgets/baloon_window"

module DGO
  module Gadgets
    class BaloonMessageWindow
      attr_reader :index
      def initialize(target_x, target_y, width, height, font, enter_texture, baloon_texture, messages = [], options = {})
        @window = BaloonWindow.new(target_x, target_y, width, height, baloon_texture, 16, options)
        @enter_texture = enter_texture
        @font = font
        @enter_y = 0
        @a = 0.2
        @index = 0
        messages.each_with_index do |message, i|
          @window.content_texture.render_shadow_text(message, (@window.content_texture.width - width) / 2, (@window.content_texture.height - height) / 2 + i * 16, @font, Color.new(33, 33, 33), Color.new(0, 0, 0, 50))
        end
      end
      
      def visible
        return @window.visible
      end
      
      def visible=(value)
        @window.visible = value
      end
      
      def update(target_x, target_y, show_width, show_height)
        @window.update(target_x, target_y, show_width, show_height)
        @enter_y += @a
        @a *= -1 if @enter_y > 5 || @enter_y <0
      end
      
      def render(s, x = 0, y = 0)
        @window.render(s, x, y)
        
        if @enter_texture
          s.render_texture(@enter_texture, x + @window.x + @window.width - 24, y + @window.y + @window.height - 13 - @enter_y)
        end
      end

    end
  end
end
