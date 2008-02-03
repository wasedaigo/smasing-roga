require  "scenes/battle/battle_lib"
require  "scenes/battle/movable"
require  "scenes/battle/unit"
require  "scenes/battle/skills/skill"

require  "lib/interval/sequence"
require  "lib/interval/parallel"
require  "lib/interval/lerp"
require  "lib/interval/loop"
require  "lib/interval/wait"
include Interval

class Battler < Unit
  include Movable

  attr_reader :no, :grid_x, :grid_y, :offset_x, :offset_y
  
  def initialize(base, battler_map, no, data)
    @battler_map = battler_map
    @grid_x = data[:grid_x]
    @grid_y = data[:grid_y]
    self.refresh_base
    
    super(base, no, @base_x, @base_y, data, 3, true, true)

    @src_width = 32
    @src_height = 32
    @controlable = true
    self.setup_movability(1)
    
    self.update
    if no == 0
    self.initialize_wait(10)
    else
    self.initialize_wait(5)
    end
  end

  def actable?
    return !self.hp_empty?
  end

  def controlable?
    return !self.hp_empty?
  end
  
  def selectable?
    return true
  end
  
  def damage_interval
    return Sequence.new(
      Lerp.new(2, 0, 4){|value|@offset_x = value},
      Lerp.new(2, -4, 0){|value|@offset_x = value},
      Lerp.new(1, -4, 0){|value|@offset_x = value}
    )
  end

  def refresh_base
    @base_x = @battler_map.map_data[@grid_x, @grid_y].x + @battler_map.offset_x
    @base_y = @battler_map.map_data[@grid_x, @grid_y].y + @battler_map.offset_y
  end
  
  def walking_animation_interval
    return BattleLib.get_animation_interval("run", self, @base.render_list, {:swap_textures=>[{:from_id=>"battlers/default", :to_id=>"#{@id}"}]})
  end

  def walk_interval(time, x, y, z)
    return  Parallel.new(
              Loop.new(-1, self.walking_animation_interval),
              self.move_interval(time, x, y, z)
            )

    return  Parallel.new(
              Loop.new(-1, self.walking_animation_interval),
              self.move_interval(time, x, y, z)
            )
  end

  def crouch_interval(time)
      Sequence.new(
        Func.new{@animating_posture = [19, 0]},
        Wait.new(time),
        Func.new{@animating_posture = [4, 0]}
      )
  end
  
  def jump_interval(time, target_x, target_y, height)
    return  Parallel.new(
              self.move_x_interval(time, @base_x),
              self.move_y_interval(time, @base_y),
              Sequence.new(
                self.move_z_interval(time / 2, height),
                self.move_z_interval(time / 2, 0)
              )
            )
  end
  
  def back_interval(target)
    return  Sequence.new(
              self.crouch_interval(10),
              self.jump_interval(10, @base_x, @base_y, 30)
            )
  end
  
  def jump_interval2(time1, time2, z)
    return  Sequence.new(
              self.crouch_interval(10),
              self.move_z_interval(time2, z)   
            )
  end
  
  def reset_animation
    @animating_posture = nil
    @visible = true
  end

  def icon_texture
    if @icon_texture.nil?
      @icon_texture = Texture.new(16,16)
      @icon_texture.render_texture(@texture, 0, 0, :src_x=> 8, :src_y =>0, :src_width => 16, :src_height => 16)
    end
    return @icon_texture
  end
  
  def width
    return @src_width
  end

  def height
    return @src_height
  end

  def think(selection_phase)
  
  end
  
  def get_before_action_interval(skill)
    return Wait.new(10){@base.render_list.register(BattleLib.get_skill_window(skill.name, self), :top)}
  end

  def get_posture_src
    return @animating_posture unless @animating_posture.nil?

    if self.hp_empty?
      return [20, 0]
    end
      
    if @posture_stack.empty?
      if self.hp_low?
        return [19, 0]
      end
    else
      case(@posture_stack.last)
        when :attack
          return [9, 0]
        when :head_back
          return [18, 0]
        when :pose
          return [14, 0]
      end
    end
    
    return [4, 0]
  end

  def set_skills
    self.skill_list.push(@base.skill_list[:cure])
    self.skill_list.push(@base.skill_list[:storm])
    self.skill_list.push(@base.skill_list[:storm])
    self.skill_list.push(@base.skill_list[:slash])
    self.skill_list.push(@base.skill_list[:slash])
    self.skill_list.push(@base.skill_list[:armagedon])
    self.skill_list.push(@base.skill_list[:cross_heal])
    self.skill_list.push(@base.skill_list[:w_slash])
    self.skill_list.push(@base.skill_list[:w_slash])
    self.skill_list.push(@base.skill_list[:cure])
    
    self.shuffle_skills
  end

  def update
    super
  end

  def render(s, x, y)
    return unless @visible
    src_x, src_y = self.get_posture_src
    options = {
      :src_x => 32 * src_x, 
      :src_y => 32 * src_y, 
      :src_width=>@src_width, 
      :src_height=>@src_height, 
      :alpha => @alpha
    }

    super(s, x, y, options)
  end
end
