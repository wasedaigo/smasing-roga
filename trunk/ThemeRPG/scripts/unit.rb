require "./scripts/table"
class Unit
  def initialize(x, y)
    @texture = Texture.load("./data/images/units/base")
    @x = x
    @y = y
    @dir = 0
    @a = 1
    @max_frame = 3
    @current_frame = 1
    
    @time = 10
    @timer = 0
  end

  def update
    if @x % 16 == 0 || @y % 16 == 0
      @dir = rand(4)
    end
    
    if @timer > @time
      if @current_frame <=0 || @current_frame >= @max_frame - 1
        @a *= -1
      end
      @current_frame += @a
      @timer = 0
    end
    @timer += 1

    case @dir
      when 0:
        @y -= 1
      when 1:
        @x += 1
      when 2:
        @y += 1
      when 3:
        @x -= 1
    end
  end
  
  def render(s, dx, dy)
    s.render_texture(@texture, @x + dx, @y + dy, :src_width => 16, :src_height => 16, :src_x => @current_frame * 16, :src_y => @dir * 16)
  end
end