require  "lib/gadgets/window"
require  "d_input"

class MessageWindow
  def initialize(x, y, width, height, text, font, colors = {})
    @text = text
    @colors = colors
    @window = Window.new(x, y, width, height, $res.get_texture("WindowFrame"))
    @font = font
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

  def refresh
    @window.content_texture.clear
    @window.content_texture.render_text(@text, 1, 1, @font, Color.new(0, 0, 0, 128))
    @window.content_texture.render_text(@text, 0, 0, @font, Color.new(255, 255, 255, 255))
  end

  def render(s)
    @window.render s
  end
end
