class Table
  attr_reader :width, :height
  attr_reader :data

  def initialize(width, height, options = {})
    @width = width
    @height = height
    
    options = {:data => nil, :init_value => nil}.merge(options)

    if options[:data] == nil
      arr = Array.new(width * height)
      arr.map!{|id|id = options[:init_value]}
      @data = arr
    else
      @data = options[:data]
    end
  end

  def size
    return [width, height]
  end

  def exists?(x, y)
    return self.has_cell?(x, y) &&  self[x, y] != nil
  end

  def has_cell?(x, y)
    return (x >= 0 && x < width && y >= 0 && y < height)
  end
  
  def fill value
    data.map! {|item| item = value}
  end

  def [](x, y)
    data[x + y * width]
  end

  def []=(x, y, value)
    data[x + y * width] = value
  end

  def each
    data.each {|item| yield item}
  end

  def map
    data.map {|item| yield item}
  end

  def each_with_index
    data.each_with_index do |item, i|
      yield [item, i]
    end
  end

  def each_with_two_index
    data.each_with_index do |item, i|
      yield [item, i % @width, i / @width]
    end
  end

  def marshal_dump
    [width, data.pack("S*")]
  end

  def marshal_load(item)
    @width = item[0]
    @data = item[1].unpack("S*")
  end
end