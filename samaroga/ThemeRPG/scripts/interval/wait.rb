module Interval
  class Wait
    attr_reader :depth, :duration

    def initialize(duration, &func)
      @depth = 1
      @duration = duration
      @func = func
    end

    def call(node)
      return false if @duration == 0
      duration = (@duration == -1) ? node[:parent].duration : @duration
      
      if node[:counter] >= duration
        return false 
      end
      node[:counter] += 1
      
      #p "Wait counter = #{node[:counter]} class = #{self}"
      @func.call(node[:counter]) unless @func.nil?
      return true
    end
  end
end