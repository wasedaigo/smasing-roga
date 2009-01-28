require "dgo/interval/sequence"
module DGO
  module Interval
    class IntervalRunner

      attr_reader :interval

      def initialize(interval = Sequence.new)
        @interval = interval
        self.reset
      end
      
      def clear
        @interval = Sequence.new
      end
      
      def done?
        return @done
      end

      def reset
        @node = {:counter => 0, :nodes => [], :parent => @interval}
        @done = @interval.duration == 0
      end
      
      def set_interval(interval)
        @interval = interval
        self.reset
      end
      
      def update
        @done = true if !done? and !@interval.call(@node)
      end
    end
  end
end
