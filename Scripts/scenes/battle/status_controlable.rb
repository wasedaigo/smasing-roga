module StatusControlable
  attr_accessor :wait_time
  attr_reader :max_time
  
  def initialize_status(max_hp)
    self.max_hp = max_hp
    self.hp = self.max_hp
  end
  
  def hp
    return @hp
  end

  def hp=(value)
    raise "Max HP is not defined yet" if self.max_hp.nil?
    @hp = self.max_hp if @hp.nil?
    t = @hp

    @hp = value
    @hp = self.max_hp if self.hp > self.max_hp
    @hp = 0 if self.hp < 0

    # unless @base.turn_bar.nil?
      # @wait_time = [@wait_time + 10, @max_time].min
      # @base.turn_bar.update_list
    # end
    
    if @hp != t
      self.update_status_texture
      push_status_event(:hp_changed)
      
      if t <= 0 && !self.hp_empty?
        self.on_revive
        push_status_event(:revive)
      end

      if t > 0 && self.hp_empty?
        self.on_dead
        push_status_event(:dead)
      end
    end
  end

  def max_hp
    return @max_hp
  end

  def max_hp=(value)
    raise("Max HP must be more than 0") if value <=0
    @max_hp = value
  end

  def hp_low?
    return self.hp < (self.max_hp / 4)
  end
  
  def hp_full?
    return self.hp == self.max_hp
  end

  def hp_empty?
    return self.hp == 0
  end

  def on_dead
    @posture_stack.clear
    #@base.battle_phase_queue.each {|obj|obj.on_unit_removed(self)}
    @base.turn_bar.update_turn_list
  end

  def on_revive
    self.reset_wait_time
    @base.turn_bar.update_turn_list
  end
  
  def push_status_event(value)
    self.get_status_events.push(value)
  end

  def status_event_exists?(value)
    return self.get_status_events.find {|i| i == value}
  end

  def clear_status_events
    self.get_status_events.clear
  end
  
  def get_status_events
    @change_status_events = [] if @change_status_events.nil?
    return @change_status_events
  end

  def status_texture
    if @status_texture.nil?
      self.update_status_texture
    end
    return @status_texture
  end

  def update_status_texture
    tone = Tone::White
    tone = Tone::Yellow if self.hp < (self.max_hp / 4)
    tone = Tone::SkyBlue if self.hp_full?
    tone = Tone::Red if self.hp_empty?
    
    @status_texture = Texture.get_number_texture("#{self.hp}/#{self.max_hp}" , :small_numbers, tone)
  end 
  
  def render_hp(s, x, y)
    s.render_texture(self.status_texture, x + @x, y + @y - 8)
  end
end
