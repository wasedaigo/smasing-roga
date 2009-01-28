module DGO
  module Interval
    class Loop

      attr_reader :duration, :loop_count

      def initialize(loop_count, interval)
        @interval = interval
        raise("infinite loop") if @interval.duration == 0
        @loop_count = loop_count
        if loop_count == -1
          @duration = -1
        else
          @duration = interval.duration * loop_count
        end
      end

      def init_node(node)
        node[:nodes] << {:counter => 0, :nodes => [], :parent => self}
      end
      
      def call(node)
        return false if @loop_count == 0
        
        self.init_node(node) if node[:nodes].empty?
        duration = (@duration == -1) ? node[:parent].duration : @duration

        return false if duration > -1 && node[:counter] >= duration
        loop do
          if @interval.call(node[:nodes][0])
            node[:counter] += 1
            return true
          else
            node[:nodes][0] = {:counter => 0, :nodes => [], :parent => self}
          end
        end
      end

    end
  end
end
