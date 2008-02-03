class TargetObject
  attr_accessor :x, :y, :z, :width, :height

  def initialize(x, y, z,  width, height)
    @x = x
    @y = y
    @z = z
    @width = width
    @height = height
  end

  def center_x
    return @x + @width / 2
  end
  
  def center_y
    return @y + @height / 2
  end
  
  def right
    return @x + @width
  end

  def bottom
    return @y + @height
  end
end
