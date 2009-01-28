module DGO
  module Interval
    class Wait

      attr_reader :duration

      def initialize(duration, &func)
        @duration = duration
        @func = func
      end

      def call(node)
        return false if @duration == 0
        duration = (@duration == -1) ? node[:parent].duration : @duration
        
        return false if node[:counter] >= duration
        node[:counter] += 1
        
        @func.call(node[:counter]) unless @func.nil?
        return true
      end

    end
  end
end
