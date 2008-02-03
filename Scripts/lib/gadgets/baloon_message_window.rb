require  "lib/gadgets/baloon_window"

class BaloonMessageWindow
  attr_reader :index

  FONT = Font.new("MS UI Gothic", 12, :bold => true)
  def initialize(target_x, target_y, width, height, message, options = {})
    @window = BaloonWindow.new(target_x, target_y, width, height, options)
    @window.update(target_x, target_y, 320, 240)
    
    @index = 0
    
    @window.content_texture.render_shadow_text(message, (@window.content_texture.width - width) / 2, (@window.content_texture.height - height) / 2, FONT, Color.new(33, 33, 33), Color.new(0, 0, 0, 50))
    
  end

  def visible
    return @window.visible
  end
  
  def visible=(value)
    @window.visible = value
  end
  
  def update(targetX, targetY, showWidth, showHeight)
    @window.update(targetX, targetY, showWidth, showHeight)
  end
  
  def render(s, x = 0, y = 0)
    @window.render(s, x, y)
  end
end
