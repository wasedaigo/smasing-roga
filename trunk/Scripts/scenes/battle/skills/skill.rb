require "lib/interval/sequence"
require "lib/interval/parallel"
require "lib/interval/func"
require "lib/interval/wait"
require "lib/interval/interval_lib"
require "lib/interval/interval_runner"

include Interval

class Skill
  attr_reader :name, :target, :group

  def initialize(id, name, target, group, options = {})
    @id = id
    @name = name
    @target = target
    @group = group
    @effect_value = options[:effect_value]? options[:effect_value].to_i : 0
    @options = options
  end

  def get_before_action_interval(user, targets)
    return  user.get_before_action_interval(self)
  end

  def get_animation_interval(base, user, targets, value)
    if value >= 0 || user.group == :enemy
      return Sequence.new
    end
    
    render_list = base.render_list
    camera = base.camera

    fx = user.x
    fy = user.y
    target = targets[0]

    str = $res.get_text_data("battle/skills/#{@id}")
    interval = eval(str)

    return interval
  end

  def get_interval(base, user, targets, select_targets)
    arr = []
    arr << Func.new{user.posture_stack.clear}
    arr << (self.get_target_view_interval(20, select_targets)) unless select_targets.empty?
    arr << (self.get_animation_interval(base, user, targets, @effect_value))
    if @effect_value < 0
      arr << (self.get_push_back_interval(5, targets, @options[:push_back]))
    end
    targets.each {|obj| obj.damage_stack += @effect_value}
    return Sequence.new(arr)
  end

  def get_push_back_interval(time, targets, push_back)
    arr =[]
    targets.each do |target|
      if target.actable?
        unless push_back.nil?
          arr << (target.get_push_back_interval(time, :right, push_back)) if target.group == :battler
        end
      end
    end
    return Parallel.new(arr)
  end
  
  def get_target_view_interval(time, targets)
    arr = []
    targets.each do |target|
      arr <<  (
                Sequence.new(
                Func.new {target.selected = true},
                Wait.new(time),
                Func.new {target.selected = false}
              )
      )
    end
    return Parallel.new(arr)
  end
end
