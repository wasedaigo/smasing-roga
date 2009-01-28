module Interval
  class Sequence
    attr_reader :depth, :duration

    def initialize(*args)
      @list = args.flatten
      t = @list.collect{|item|item.depth}.max
      @depth = t.nil? ? 1 : t + 1
      @duration = @list.inject(0) {|result, item| result + item.duration}
    end
    
    def init_node(node)
      @list.each{node[:nodes] << {:counter => 0, :nodes => [], :parent => node}}
    end

    def call(node)
      return false if @depth <= 1
      self.init_node(node) if node[:nodes].empty?
      #p "sequence counter = #{node[:counter]}"
      loop do
        return false if node[:counter] >= @list.length
        if @list[node[:counter]].call(node[:nodes][node[:counter]])
          return true
        else
          node[:counter] += 1
        end
      end
    end
  end
end