module DGO
  module Geometry
    class Rectangle

      attr_reader :left, :top, :width, :height

      def initialize(left, top, width, height)
        raise "width should be more than 0" if width <= 0
        raise "height should be more than 0" if height <= 0
        @top = top
        @left = left
        @width = width
        @height = height
      end

      def h_middle 
        return @left + @width / 2
      end
      
      def v_middle 
        return @top + @height / 2
      end
      
      def right
        return @left + @width
      end

      def bottom
        return @top + @height
      end

      def include?(x, y)
        return left <=x && x <= right && top <= y && y <= bottom
      end
    end
  end
end
