module DGO
  module Table
    class Table

      attr_reader :width
      attr_reader :data

      def initialize(width, data)
        @width = width
        @data = data
      end

      def height
        @height ||= data.size / @width
      end

      def size
        [width, height]
      end

      def exists?(x, y)
        return has_cell?(x, y) && self[x, y]
      end

      def has_cell?(x, y)
        return x >= 0 && x < width && y >= 0 && y < height
      end
      
      def fill(value)
        data.map! {|obj| obj = value}
      end

      def [](x, y)
        #raise IndexError unless exists?(x, y)
        data[x + y * width]
      end

      def []=(x, y, value)
        #raise IndexError unless exists?(x, y)
        data[x + y * width] = value
      end

      def each
        data.each {|obj| yield obj}
      end

      def map
        data.map {|obj| yield obj}
      end

      def set_size(w, h)
        t = Array.new(w * h)
        
        (0..(w - 1)).each do |i|
          break if i >= @width
          (0..(h - 1)).each do |j|
            break if j >= @height
            t[i + j * w] = self[i, j]
          end
        end
        
        @width = w
        @height = h
        @data = t
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
      
      def map
        yield data.map {|v| yield v}
      end
      
      def map!
        yield data.map! {|v| yield v}
      end
      
      def marshal_dump
        [width, data.pack("S*")]
      end

      def marshal_load(obj)
        @width = obj[0]
        @data = obj[1].unpack("S*")
      end

    end
  end
end
