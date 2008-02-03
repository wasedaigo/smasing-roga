class Target
  def create_free_selected_list(list)
    t_list = []
    list.collect{|obj| obj.x}.uniq.sort.each do |value|
      t_list.push(list.select{|obj| obj.x == value}.sort{|obj1, obj2|obj1.y <=> obj2.y})
    end
    return t_list
  end

  def get_casting_targets(base, user, targets)
    return targets
  end
  
  def get_effect_targets(base, user, targets)
    return []
  end

  def get_next_target
    return nil
  end

  def get_targets(base, user, target)
    return [target]
  end
  
  def get_selected_target(base, user, target)
    return target
  end

  def get_selectable_targets(base, user, selected_targets)
    raise "this method should be overwritten"
  end
  
  def get_selecting_targets(base, user, selected_targets)
    return self.get_selectable_targets(base, user, selected_targets).flatten
  end

  def render_cursor(s, x, y, type, target)
    case(type)
    when :all
      target.each {|obj| obj.each{|obj| s.render_texture($res.get_texture("Cursor"), x + obj.x, y + obj.y)} }
    when :one
      s.render_texture($res.get_texture("Cursor"), x + target.x, y + target.y)
    end  
  end
end
