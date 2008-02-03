class Rectangle
  attr_reader :left, :top, :width, :height

  def initialize left, top, width,height
    raise "width should be more than 0" if width <= 0
    raise "height should be more than 0" if height <= 0
    @top = top
    @left = left
    @width = width
    @height = height
  end

  def right
    return @left + @width
  end

  def bottom
    return @top + @height
  end
end
