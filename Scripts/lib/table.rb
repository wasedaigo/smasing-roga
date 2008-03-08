class Table

  attr_reader :width
  attr_reader :data

  def initialize width, data
    @width = width
    @data = data
  end

  def height
    return @height ||= data.size / width
  end

  def size
    return [width, height]
  end

  def exists?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end

  def fill value
    data.map! {|obj| obj = value}
  end

  def [](x, y)
    data[x + y * width]
  end

  def []=(x, y, value)
    data[x + y * width] = value
  end

  def each
    data.each {|obj| yield obj}
  end

  def map
    data.map {|obj| yield obj}
  end

  def each_with_index
    data.each_with_index do |obj, i|
      yield [obj, i]
    end
  end

  def each_with_two_index
    data.each_with_index do |obj, i|
      yield [obj, i % @width, i / @width]
    end
  end

  def marshal_dump
    [width, data.pack("S*")]
  end

  def marshal_load obj
    @width = obj[0]
    @data = obj[1].unpack("S*")
  end
end
