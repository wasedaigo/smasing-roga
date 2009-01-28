module Interval
  class Func
    attr_reader :depth, :duration
    def initialize(&func)
      @func = func
      @depth = 1
      @duration = 0
    end

    def call(node)
      @func.call unless @func.nil?
      return false
    end
  end
end
