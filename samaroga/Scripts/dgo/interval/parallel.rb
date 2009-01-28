module DGO
  module Interval
    class Parallel

      attr_reader :duration

      def initialize(*args)
        @list = args.flatten
        t = @list.collect {|obj| obj.duration }.max
        @duration = t.nil? ? 0 : t
      end

      def init_node(node)
        @list.each{node[:nodes] << {:counter => 0, :nodes => [], :parent => self}}
      end

      def call(node)
        self.init_node(node) if node[:nodes].empty?

        b = false
        @list.each_with_index do |obj, i|
          next if node[:counter] > obj.duration && obj.duration != -1
          if obj.call(node[:nodes][i])
            b = true
          end
        end

        node[:counter] += 1 if b
        return b
      end

    end
  end
end
