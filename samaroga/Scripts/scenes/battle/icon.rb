class ICON
  def self.render_skill_icon(s, type, x, y)
    case type
    when :attack
      t = 0
    when :guard
      t = 1
    when :support  
      t = 2
    when :heal
      t = 3
    when :chain
      t = 4
    else
      raise("this must not be called")
    end
    s.render_texture($res.get_texture("command_icons"), x, y, :src_x => 14 * t, :src_width => 14)
  end
end