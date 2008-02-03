require  "lib/gadgets/window"
class BaloonWindow
  GRID_SIZE = Window::GRID_SIZE
  
  TEXTURE = $res.get_texture("window/baloon_window")
  
  attr_reader :x
  attr_reader :y

  attr_accessor :visible

  def initialize(target_x, target_y, width, height, options = {})
    @x = 0
    @y = 0
    @arrowX = 0
    @arrowDirX = -1
    @arrowDirY = -1
    @visible = true
    @options = options
    @window = Window.new(0, 0, [width, 48].max, height, TEXTURE)
    self.update(target_x, target_y, width, height)
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
    tx = target_x - self.width/2
    t = tx
    ty = target_y - self.height

    tx = 0 if tx < 0
    tx = show_width - self.width if tx + self.width > show_width

    @arrowX = t - tx + self.width / 2 - GRID_SIZE

    @arrowX = 0 if @arrowX < 0
    @arrowX = self.width - GRID_SIZE if @arrowX > self.width - GRID_SIZE

    case @options[:x_fixed]
      when :left
        @arrowDirX = -1
      when :right
        @arrowDirX = 1
      else
        if target_x > show_width / 2
          @arrowDirX = 1
        else
          @arrowDirX = -1
        end
    end

    @arrowDirY = 1

    case @options[:y_fixed]
      when :up
        @arrowDirY = -1
      when :down
        @arrowDirY = 1
      else
        if ty + height > show_height
          @arrowDirY = 1
        end
        if ty < 0
          ty = target_y + 48
          @arrowDirY = -1
        end
    end

    @x = tx
    @y = ty
  end

  def render(s, x = 0, y = 0)
    return unless @visible

    alpha = 255
    @window.render(s, x + @x, y + @y, :alpha => alpha)

    if @arrowDirY == -1
      s.render_texture(TEXTURE, x + @x + @arrowX - GRID_SIZE * (@arrowDirX * 0.5), y + @y - GRID_SIZE + 3, :alpha => alpha, :src_x=>(2 + (1 + @arrowDirX)/2) * GRID_SIZE ,:src_y=>0, :src_width => GRID_SIZE, :src_height => GRID_SIZE)
    end
    if @arrowDirY == 1
      s.render_texture(TEXTURE, x + @x + @arrowX - GRID_SIZE * (@arrowDirX * 0.5), y + @y + (height - 3), :alpha => alpha, :src_x=>(2 + (1 + @arrowDirX)/2) * GRID_SIZE ,:src_y => GRID_SIZE, :src_width => GRID_SIZE, :src_height => GRID_SIZE)
    end

    s.render_texture(content_texture, x + @x + GRID_SIZE / 2, y + @y + GRID_SIZE / 2)
  end


end
