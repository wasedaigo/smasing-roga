module Interval
  class Lerp
    attr_reader :depth, :duration

    def initialize(duration, from_value, to_value, options = {}, &func)
      @func = func
      @from_value = from_value
      @to_value = to_value
      @duration = duration
      @depth = 1
      @options = options
      @options["type"] = :ease_in_out
    end

    def value(counter)
      if @options["type"] == :ease_in_out
        t = counter/@duration.to_f
        t1 = (@to_value - @from_value) * ((Math::cos(Math::PI * t) + 1) / 2)
        t2 = @to_value - t1
      else
        t2 = (@to_value * counter + @from_value * (@duration - counter)) / @duration.to_f
      end
      return t2
    end

    def call(node)
      return false if @duration == 0
      duration = (@duration == -1) ? node[:parent].duration : @duration
      if node[:counter] < 0 || node[:counter] >= duration
        return false 
      end
      node[:counter] += 1
      @func.call(self.value(node[:counter])) unless @func.nil?
      return true
    end
  end
end