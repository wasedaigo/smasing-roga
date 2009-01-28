module Interval
  class IntervalRunner
    attr_reader :interval, :duration, :depth
    def initialize(interval = nil)
      @interval = interval
      self.reset
    end
    
    def done?
      return @done
    end

    def reset
      if @interval.nil?
        @done = true
      else
        raise("incorrect depth") if @interval.depth <=0
        @node = {:counter => 0, :nodes => [], :parent => @interval}
        @done = false
      end
    end
    
    def update
      unless self.done?
        unless @interval.call(@node)
          @done = true
        end
      end
    end
  end
end
