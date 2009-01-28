module DGO
  module Interval
    class Sequence

      attr_reader :duration

      def initialize(*args)
        @list = args.flatten
        if @list.any? {|v| v.duration == -1}
          @duration = -1
        else
          @duration = @list.inject(0) {|result, item| result + item.duration}
        end
      end

      def init_node(node)
        @list.each{node[:nodes] << {:counter => 0, :nodes => [], :parent => self}}
      end

      def call(node)
        self.init_node(node) if node[:nodes].empty?
        loop do
          return false if node[:counter] >= @list.length
          if @list[node[:counter]].call(node[:nodes][node[:counter]])
            return true
          else
            node[:counter] += 1
          end
        end
      end

    end
  end
end
