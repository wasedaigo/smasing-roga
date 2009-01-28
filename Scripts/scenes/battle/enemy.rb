require  "scenes/battle/unit"
require "scenes/battle/skills/skill"
require "scenes/battle/battle_lib"
require "dgo/interval/sequence"
require "dgo/interval/wait"
require "dgo/interval/func"
require "dgo/interval/lerp"
require "dgo/interval/Parallel"
include DGO::Interval

class Enemy < Unit
  def initialize(base, no, data)
    super(base, no, data[:x], data[:y], data, 3, true, true)
    @enemy_type = data[:enemy_type]

    case(@enemy_type)
      when :beast
        @icon_texture = $res.get_texture("beast_icon").dup
        @icon_texture.render_texture($res.get_texture("font"), 7, 8, :src_x => 9 * no, :src_width => 9, :src_height => 9)
    end
    self.initialize_wait(5)
    self.update  
  end

  def actable?
    return !self.hp_empty?
  end
  
  def controlable?
    return @controlable
  end
  
  def selectable?
    return true
  end
  
  def height
    return @texture.height
  end

  def width
    return @texture.width
  end

  def damage_interval
    return Sequence.new(
      Lerp.new(2, 0, 4){|value|@offset_x = value},
      Lerp.new(2, -4, 0){|value|@offset_x = value},
      Lerp.new(1, -4, 0){|value|@offset_x = value}
    )
  end
  
  def get_random_action
    def get_random_index(list)
      return (rand * list.size).floor
    end
    index = get_random_index(self.active_skill_list)
    return :type => :ok, :index => index, :action => {:unit => self, :command => self.active_skill_list[index][:command], :targets => [@base.battler_list[get_random_index(@base.battler_list)]]}
  end

  def think(selection_phase)
    #if @base.battle_phase.task_empty?
      selection_phase.turn_end(get_random_action)
    #end
  end
  
  def get_before_action_interval(command)
    return Sequence.new(
      BattleLib.get_target_blink_interval(self, 4, Tone.get_tone(0, 0, 0, 255), Tone.get_tone(180, 180, 180, 255)),
      BattleLib.get_target_blink_interval(self, 4, Tone.get_tone(0, 0, 0, 255), Tone.get_tone(180, 180, 180, 255))
    )
  end
  
  def get_skill_window_interval(command)
    Wait.new(20){@base.render_list.register(BattleLib.get_skill_window(command.name, self), :top)}
  end
  
  def get_dead_interval(list)
    return Sequence.new(
      Lerp.new(50, 255, 0){|value|@alpha = value},
      Func.new{list.delete(self)}
    )
  end

  def set_skills
    self.skill_list.push(@base.skill_list[:fang])
    self.skill_list.push(@base.skill_list[:smash])
    self.skill_list.push(@base.skill_list[:smash])
    self.skill_list.push(@base.skill_list[:fang])
    self.skill_list.push(@base.skill_list[:fire_breath])
    self.skill_list.push(@base.skill_list[:smash])
    self.skill_list.push(@base.skill_list[:inferno])
    
    self.shuffle_skills
  end

  def update
    super
  end
  
  def render(s, x, y)
    options = {
      :alpha => @alpha
    }
    super(s, x, y, options)
  end
end
