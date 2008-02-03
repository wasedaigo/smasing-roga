require  "scenes/battle/skill_equipable"
require  "scenes/battle/status_controlable"
require  "scenes/battle/waitable"

require  "lib/interval/sequence"
require  "lib/interval/parallel"
require  "lib/interval/lerp"
require  "lib/interval/loop"
require  "lib/interval/wait"
include Interval

class Unit
  include StatusControlable
  include SkillEquipable
  include Waitable
  attr_accessor :selected, :select_state, :damage_stack, :alpha, :tone, :angle, :visible
  attr_reader :name, :id, :no, :group, :posture_stack, :icon_texture, :show_menu, :x, :y, :z

  
  def initialize(base, no, x, y, data, card_number, controlable, show_menu)
    @base = base
    @damage_stack = 0
    @name = data[:name]
    @no = no
    
    @group = data[:group]

    @x = x
    @y = y
    @z = 0
    @vx = 0
    @vy = 0
    @vz = 0
    
    @id = data[:id]
    @texture = $res.get_texture(id)

    @alpha = 255
    @tone = Tone.get_tone(0, 0, 0, 255)
    @angle = 0
    @angular_velocity = 0
    
    @selected = false
    @select_state = :none
    @posture_stack = []

    @visible = true
    @controlable = controlable
    @show_menu = show_menu
    self.initialize_wait((rand * 20).floor + 5)
    self.initialize_status((rand * 20).floor * 5 + 50)
    self.initialize_skill_equip(card_number)

    
    data[:skills].each do |item|
      (1..item[1]).each do
        self.skill_list << $res.get_skill(item[0])
      end
    end
    self.shuffle_skills
  end
  
  def center_x
    return @x + self.width / 2
  end
  
  def center_y
    return @y + self.height / 2 
  end
    
  def right
    return @x + self.width
  end
  
  def bottom
    return @y + self.height
  end
  
  def move_x_interval(time, x)
    return Lerp.new(time, 0.0, 1.0) do |value| 
      t = @x if t.nil?
      @x = (t + (x - t) * value).round
    end
  end
 
  def move_y_interval(time, y)
    return Lerp.new(time, 0.0, 1.0) do |value| 
      t = @y if t.nil?
      @y = (t + (y - t) * value).round
    end
  end

  def move_z_interval(time, z)
    return Lerp.new(time, 0.0, 1.0) do |value| 
      t = @z if t.nil?
      @z = (t + (z - t) * value).round
    end
  end

  def move_interval(time, x, y, z)
    return Parallel.new(
            self.move_x_interval(time, x),
            self.move_y_interval(time, y),
            self.move_z_interval(time, z)
           )
  end
  
  # def relative_move_x_interval(time, to_x)
    # return self.move_y_interval(time, @x, to_x)
  # end
 
  # def relative_move_y_interval(time, to_y)
    # return self.move_y_interval(time, @y, to_y)
  # end
  
  # def relative_move_interval(time, to_x, to_y)
    # return Parallel.new(
            # self.relative_move_x_interval(time, to_x),
            # self.relative_move_y_interval(time, to_y)
           # )
  # end
 
  def set_angle_interval(time, angle)
    return Lerp.new(time, 0.0, 1.0) do |value|
      if t.nil?
        t = @angle 
        self.angular_velocity = 0
      end
      @angle = (t + (angle - t) * value).round
    end
  end

  def rotation_interval(time)
    return Lerp.new(time, 0.0, 1.0){|value|@angle = 2 * Math::PI * value}
  end

  def start_rotation(speed)
    return Func.new{self.angular_velocity}
  end

  # def add_force(x, y, z)
    # @vx = x
    # @vy = y
    # @vz = z
  # end
  
  def update
    # @angle += @angular_velocity
    # g = -1.0
    
    # @vz += g
    # @x += @vx
    # @y += @vy
    # @z += @vz
    
    # if @z <= 0
      # @z = 0
      # @vz = 0
    # end
  end
  
  def render(s, x, y, options)
    options.merge!(:center_x => self.width/2, :center_y => self.height/2)
    if @selected
      options.merge!(BattleLib.get_blink_tone(@base.blink_counter))
      s.render_texture(@texture, x + @x, y + @y - @z, options)
    else
      options.merge!(@tone)
      options.merge!(:angle => @angle)
      s.render_texture(@texture, x + @x, y + @y - @z, options)
    end
    
    self.render_hp(s, x, y) unless @base.battle_phase.running?
  end
  
  def to_s
    return self.name
  end
end