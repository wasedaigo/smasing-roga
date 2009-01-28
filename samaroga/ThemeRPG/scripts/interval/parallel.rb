module Interval
  class Parallel
    attr_reader :depth, :duration

    def initialize(*args)
      @list = args.flatten
      t = @list.collect{|item|item.depth}.max
      @depth = t.nil? ? 1 : t + 1
      t = @list.collect {|obj| obj.duration }.max
      @duration = t.nil? ? 0 : t
    end

    def init_node(node)
      @list.each{node[:nodes] << {:counter => 0, :nodes => [], :parent => self}}
    end

    def call(node)
      return false if @depth <= 1
      self.init_node(node) if node[:nodes].empty?

      @list[node[:counter]]
      b = false
      @list.each_with_index do |obj, i|
        next if node[:counter] > obj.duration && obj.duration != -1
        if obj.call(node[:nodes][i])
          b = true
        end
      end

      if b
        node[:counter] += 1
        return true
      else
        return false
      end
    end
  end
end