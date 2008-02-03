require "scenes/battle/targets/target"
class RectangleTileTarget < Target
  def initialize(width, height, count = 1)
    @width = width
    @height = height
    @count = count
  end

  def get_width(base)
    return (@width < 0) ? base.battler_map.w_count : @width
  end
  
  def get_height(base)
    return (@height < 0) ? base.battler_map.h_count : @height
  end
  
  def get_casting_targets(base, user, targets)
    arr = []
    self.get_targets(base, user, targets[0]).each do |obj|
      arr.push(obj.get_unit) unless obj.get_unit.nil?
    end
    return arr
  end

  def get_effect_targets(base, user, targets)
    return self.get_targets(base, user, targets[0])
  end
  
  def get_selectable_targets(base, user, selected_targets)
    list = base.battler_map.get_tiles(0, 0, :rectangle, :width => base.battler_map.w_count - self.get_width(base) + 1, :height => base.battler_map.h_count - self.get_height(base) + 1)
    return self.create_free_selected_list(list)
  end
  
  def get_selecting_targets(base, user, selected_targets)
    return base.battler_map.map_data.data
  end
  
  def get_targets(base, user, target)
    return base.battler_map.get_tiles(target.grid_x, target.grid_y, :rectangle, :width => self.get_width(base), :height => self.get_height(base))
  end

  def render_cursor(s, x, y, options = {})
  end
end