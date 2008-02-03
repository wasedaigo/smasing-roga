require  "lib/gadgets/baloon_window"

class BaloonMenuWindow < BaloonWindow
  CURSOR_TEXTURE = Texture.load "Images/Cursor"

  attr_reader :index

  def initialize(target_x, target_y, width, height, commands, colors)
    super (target_x, target_y, width, height)
    @index = 0
    (@commands = commands).each_with_index do |command, i|
      t = content_texture
      x = 0.5 * GRID_SIZE
      y = i * GRID_SIZE + 2
      t.render_text(command, x + 1, y + 1, FONT, Color.new(0, 0, 0, 128))
      t.render_text(command, x, y, FONT, (colors[i] || Color.new(255, 255, 255)))
    end
  end

  def update targetX, targetY, showWidth, showHeight
    super targetX, targetY, showWidth, showHeight
    if Input.pressed_newly? :ok
      yield @index
    else
      @index += 1 if Input.pressed_repeating? :down
      @index -= 1 if Input.pressed_repeating? :up
      @index = [[@index, @commands.size - 1].min, 0].max
    end
  end

  def render(s)
    super(s)
    s.render_texture(CURSOR_TEXTURE, @x, @y + (index + 0.5) * GRID_SIZE + 2)
  end
end
