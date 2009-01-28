class ActionTaskManager
  def initialize
    @tasks = []
    @chaining = false
    @chain_tasks = []
  end
  
  def acting?(unit)
    @tasks.each do |obj|
      return true if obj.user == unit
    end
    return false
  end
  
  def chaining?
    return @chaining
  end
  
  def empty?
    return @tasks.empty?
  end

  def chaining_target
    return @target
  end
  
  def push(obj)
    @tasks.push(obj)
  end

  def reject_invalid_tasks
    @tasks.reject! {|obj|obj != @tasks.last && !obj.user.actable?}
  end

  def update
    t = @tasks.last
    @tasks.each{|obj|obj.update(@tasks)}
    @tasks.reject!{|obj|obj.done?}
    if self.empty?
      @target = nil
      @chaining = false
      @chain_tasks.clear
      yield
    end
  end
end