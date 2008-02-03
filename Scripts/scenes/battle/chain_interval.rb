require "lib/interval/sequence"
require "lib/interval/func"
require "lib/interval/wait"
module Interval
  class ChainInterval
    attr_accessor :duration
    def initialize(base, duration)
      @interval = Sequence.new(
        Func.new{base.chain_inputtable = true},
        Wait.new(duration),
        Func.new{base.chain_inputtable = false}
      )
    end

    def duration?
      return @interval.done?
    end
    
    def done?
      return @interval.done?
    end

    def loop?
      return @interval.loop?
    end
    
    def wait?
      return @interval.wait?
    end

    def reset
      @interval.reset
    end

    def update
      @interval.update
    end
  end
end
