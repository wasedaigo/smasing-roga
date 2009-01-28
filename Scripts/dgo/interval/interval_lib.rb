require "dgo/interval/sequence"
require "dgo/interval/parallel"
require "dgo/interval/lerp"
require "dgo/interval/loop"
require "dgo/interval/func"

module DGO
  module Interval
    def self.get_blink_interval(time, start_value, end_value, loop, &proc)
      seq = Sequence.new(
              Lerp.new(time, start_value, end_value){|value|proc.call(value)},
              Lerp.new(time, end_value, start_value){|value|proc.call(value)}
            )
      if loop
        return Loop.new(-1, seq)
      else
        return seq
      end
    end
    
    def self.get_sound_interval(id, options = {})
      return Func.new {$res.play_se(id)}
    end
  end
end