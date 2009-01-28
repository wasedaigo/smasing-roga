module DGO
  module Interval
    class Lerp
      attr_reader :duration

      def initialize(duration, from_value, to_value, options = {}, &func)
        @func = func
        @from_value = from_value
        @to_value = to_value
        @duration = duration
        @options = options
        @options["type"] = :linear
      end

      def value(counter)
        if @options["type"] == :ease_in_out
          t = counter/@duration.to_f
          t1 = (@to_value - @from_value) * ((Math::cos(Math::PI * t) + 1) / 2)
          return @to_value - t1
        else
          return (@to_value * counter + @from_value * (@duration - counter)) / @duration.to_f
        end
      end

      def call(node)
        return false if @duration == 0
        duration = (@duration == -1) ? node[:parent].duration : @duration
        return false  if node[:counter] < 0 || node[:counter] >= duration
        node[:counter] += 1
        @func.call(self.value(node[:counter])) unless @func.nil?
        return true
      end

    end
  end
end
