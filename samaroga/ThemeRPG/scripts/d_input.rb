module DInput
  def self.swap_key(key)
    case key
    when :cancel
      key = :escape
    when :ok
      key = :space
    end

    return key
  end

  def self.pressed?(key, device = :keyboard)
    key = self.swap_key(key)
    return Input.keys(device).include?(key)
  end

  def self.pressed_newly?(key, device = :keyboard)
    key = self.swap_key(key)
    return Input.keys(device, :duration=>1).include?(key)
  end

  def self.pressed_repeating?(key, device = :keyboard)
    key = self.swap_key key
    return Input.keys(device, :duration=>1, :delay=>4).include?(key)
  end
  
  
end