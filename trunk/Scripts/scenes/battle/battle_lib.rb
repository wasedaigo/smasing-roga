require  "dgo/gadgets/baloon_message_window"
require  "dgo/graphics/sprite"


require  "dgo/interval/sequence"
require  "dgo/interval/lerp"

class BattleLib
  attr_accessor :font
  @font = $font
  include DGO::Interval
  include DGO::Gadgets
  include DGO::Graphics
  # a window shows up before battlers' action
  def self.get_skill_window(name, unit)
    w, h = FONT.get_size(name)
    
    case unit.group
      when :battler
        return BaloonMessageWindow.new(unit.x, unit.y, w, h, FONT, nil, $res.get_texture("window/baloon_window"), [name], :x_fixed => :right, :y_fixed => :down)
      when :enemy
        return BaloonMessageWindow.new(unit.x + unit.width, unit.y, w, h, FONT, nil, $res.get_texture("window/baloon_window"), [name], :x_fixed => :left, :y_fixed => :down)
      else
        raise("case #{unit.group} is not defined yet")
    end
  end

  # blink the target
  def self.get_target_blink_interval(target, time, start_tone, end_tone, loop = false)
    return Parallel.new(
            DGO::Interval.get_blink_interval(time, start_tone[:tone_red], end_tone[:tone_red], loop) { |value| target.tone[:tone_red] = value},
            DGO::Interval.get_blink_interval(time, start_tone[:tone_green], end_tone[:tone_green], loop) { |value| target.tone[:tone_green] = value},
            DGO::Interval.get_blink_interval(time, start_tone[:tone_blue], end_tone[:tone_blue], loop) { |value| target.tone[:tone_blue] = value},
            DGO::Interval.get_blink_interval(time, start_tone[:saturation], end_tone[:saturation], loop) { |value| target.tone[:saturation] = value}
           )
  end
  
  # get effect
  def self.get_typed_target_blink_interval(target, type)
    case type
    when :recover
      return self.get_target_blink_interval(target, 6, Tone.get_tone(0, 0, 0, 255), Tone.get_tone(80, 160, 80, 255))
    when :temp_damage
      return self.get_target_blink_interval(target, 6, Tone.get_tone(0, 0, 0, 255), Tone.get_tone(100, 20, 20, 255))
    when :damage
      return self.get_target_blink_interval(target, 6, Tone.get_tone(0, 0, 0, 255), Tone.get_tone(255, 30, 30, 255))
    when :select
      return self.get_target_blink_interval(target, 6, Tone.get_tone(0, 0, 0, 255), Tone.get_tone(80, 80, 80, 255))
    end
  end

  # pop up damage or recover
  def self.get_value_popup_interval(x, y, value, type, render_list)
    case type
    when :recover
      options = Tone.get_tone( -200, 0, -200, 255)
    when :damage
      options = {}
    else
      raise "this must not be called"
    end

    value = value.abs
    texture = Texture.get_number_texture(value, :medium_numbers, options)
    sprite = Sprite.new(texture, x, y)

    func = proc do |value|
        sprite.y = value
        render_list.register(sprite, :middle_top)
      end
 
    return Sequence.new(
      Lerp.new(5, y, y - 10) {|value| func.call(value)},
      Lerp.new(5, y - 10, y - 5) {|value| func.call(value)},
      Lerp.new(5, y - 5, y - 8) {|value| func.call(value)},
      Lerp.new(5, y - 8, y - 5) {|value| func.call(value)},
      Wait.new(20) {func.call(y - 5)}
    )
  end

  def self.get_blink_alpha(value)
    return 150 + value * 50
  end

  def self.get_blink_tone(value, type = :white)
    case type
    when :white
      return Tone.get_tone(100 + 50 * value, 100 + 50 * value, 100 + 50 * value, 255)
    when :red
      return Tone.get_tone(150 + 50 * value, 0 + 50 * value, 0 + 100 * value, 255)
    when :green
      return Tone.get_tone(50 + 50 * value, 150 + 50 * value, 50 + 100 * value, 255)
    end
  end

  def self.get_damage_effect_interval(value, targets, render_list)
    type = value > 0 ? :recover : :temp_damage
    par = Parallel.new
    targets.each_with_index do |target,i|
      par.push(self.get_typed_target_blink_interval(target, type))
    end
    return par
  end
  
  # show damage or recover
  def self.process_damage_interval(target, type, value, render_list)
    return  Sequence.new(
              self.get_typed_target_blink_interval(target, type),
              self.get_value_popup_interval(target.x, target.y, value, type, render_list),
              Func.new{target.hp += value}
            )
  end
  
  def self.get_damage_interval(targets, render_list)

    arr1 = []
    targets.each_with_index do |target,i|
      next if target.damage_stack == 0
      value = target.damage_stack
      target.damage_stack = 0
      type = value > 0 ? :recover : :damage
      t_value = value

      arr2 = []
      arr2 << Func.new{target.posture_stack.push(:head_back)} if type == :damage
      arr2 << self.process_damage_interval(target, type, t_value, render_list)
      arr2 << Func.new{target.posture_stack.pop} if type == :damage
      arr1 << Sequence.new(arr2)
    end

    return Parallel.new(arr1)
  end

  # get anime
  def self.get_animation_interval(name, target, render_list, options = {})    
    $res.get_animation_frame(name)
    return  Animation.new($res.get_animation_frame(name), target, options) do |obj|
              render_list.register(obj, :middle_top)
            end
  end
end
