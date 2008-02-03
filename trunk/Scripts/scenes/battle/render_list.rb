require 'benchmark'
class RenderList
  
  def initialize
    @list = []
    @priorities = {
      :bottom => 0,
      :middle => 1,
      :top => 2,
      :middle_top => 3,
      :over_top => 4
    }
  end

  def clear
    @list.clear
  end

  def register(obj, priority, sub = 0)
    @list.push([obj, priority, sub])
  end
  
  def render(s, x, y, option = nil)
    i = 0
    list = []
    if option == :render_over_top
      list = @list.select{|obj|obj[1] == :over_top}
    else
      list = @list.select{|obj|obj[1] != :over_top}.sort_by {|obj| [@priorities[obj[1]] , i += 1]}
    end
    
    list.each do |obj|
      obj[0].render(s, x, y)
      # t = Benchmark.measure {obj[0].render(s, x, y)}
      # p "#{obj[0]}:#{t}"
    end
  end
end