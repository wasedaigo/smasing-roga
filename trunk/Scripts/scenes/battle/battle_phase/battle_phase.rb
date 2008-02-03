require  "scenes/battle/battle_phase/action_task"
require  "scenes/battle/battle_phase/action_task_manager"
require  "scenes/battle/loss_phase/loss_phase"
require  "scenes/battle/victory_phase/victory_phase"
require  "scenes/battle/targets/battler_target"
require  "scenes/battle/targets/rectangle_tile_target"
require "lib/interval/sequence"
require "lib/interval/wait"
require "lib/interval/func"
require "lib/interval/Parallel"
require "lib/interval/interval_runner"
require "lib/target_object"
require "d_input"
include Interval

class BattlePhase
  def initialize(base)
    @base = base
    @window = nil
    @damages = []
    @action_task_manager = ActionTaskManager.new
    @counter = 0
    @time = 100
    @interval_runner = IntervalRunner.new
  end

  def acting?(unit)
    @action_task_manager.acting?(unit)
  end
  
  def chainable?
    return !@action_task_manager.chaining_target.nil?
  end
  
  def chaining_target
    return @action_task_manager.chaining_target
  end
  
  def running?
    return !(@action_task_manager.empty? && @interval_runner.done?)
  end
  
  def push_action(interval)
    @action_task_manager.push(ActionTask.new(interval))
  end

  def start_action(action)
      t_interval =  action[:command].get_interval(
                      @base,
                      action[:unit], 
                      action[:command].target.get_casting_targets(@base, action[:unit], action[:targets]), 
                      action[:command].target.get_effect_targets(@base, action[:unit], action[:targets])
                    )
  
      interval =  Sequence.new(
                    action[:command].get_before_action_interval(action[:unit], action[:targets]),
                    Func.new{self.push_action(t_interval)}
                  )
                  
    self.push_action(interval)
  end

  def next_action
    #@base.turn_bar.next
    
    action = @base.command_list.shift[:action]
    
    #@base.selection_phase.update_title_window(action[:unit], [action])

    interval =  action[:command].get_interval(
                      @base,
                      action[:unit], 
                      action[:command].target.get_casting_targets(@base, action[:unit], action[:targets]), 
                      action[:command].target.get_effect_targets(@base, action[:unit], action[:targets])
                    )
                  
    self.push_action(interval)
  end

  def finish_action_interval(time)
    Sequence.new(
      @base.camera.get_focus_interval(time, 1),
      BattleLib.get_damage_interval(@base.unit_list,  @base.render_list)
    )
  end

  def next_action_interval(time)
    Sequence.new(
      @base.camera.get_focus_interval(time, 1),
      BattleLib.get_damage_interval(@base.unit_list,  @base.render_list),
      Func.new{self.next_action}
    )
  end

  def update(queue)
    if @interval_runner.done?
      unless @action_task_manager.empty?
        unless @base.command_list.empty?
          self.next_action
        end
        @action_task_manager.update do
          if @base.command_list.empty?
            @interval_runner = IntervalRunner.new(self.finish_action_interval(6))
          else
            @interval_runner = IntervalRunner.new(self.next_action_interval(6))
          end
        end
      end

      arr = []
      @base.enemy_list.each do |obj|
        arr << obj.get_dead_interval(@base.enemy_list) if obj.hp <= 0
      end
      @interval_runner = IntervalRunner.new(Parallel.new(arr)) unless arr.empty?
    else
      @interval_runner.update
    end
  end
end
