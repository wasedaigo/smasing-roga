require  "lib/gadgets/window"
require  "lib/gadgets/menu_window"

class BattleMenuWindow
  FONT = Font.new("MS UI Gothic", 12)
  attr_accessor :visible, :title

  def initialize(title, x, y, width, height, commands = [])
    @title = title
    @visible = true
    @menuWindow = MenuWindow.new(x, y + MenuWindow::GRID_SIZE * 2, width, height, commands, $font)
    @titleWindow = Window.new(x, y, width, Window::GRID_SIZE * 2, $res.get_texture("WindowFrame"))
    self.refresh
  end

  def x=(value)
    @menuWindow.x = value
    @titleWindow.x = value
  end

  def y=(value)
    @menuWindow.y = value + MenuWindow::GRID_SIZE * 2
    @titleWindow.y = value
  end

  def clear
    @menuWindow.clear
  end

  def refresh
    @menuWindow.refresh

    t =  @titleWindow.content_texture
    t.clear
    t.render_text(title, 1, 1, FONT, Color.new(0, 0, 0, 128))
    t.render_text(title, 0, 0, FONT,Color.new(255,255,255,255))
  end

  def <<(obj)
    @menuWindow << obj
  end

  def update
    @menuWindow.update do |index|
      yield index
    end
  end

  def render(s)
    return unless @visible
    @menuWindow.render(s)
    @titleWindow.render(s)
  end
end
