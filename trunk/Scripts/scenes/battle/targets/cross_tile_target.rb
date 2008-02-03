require "scenes/battle/targets/target"
class CrossTileTarget < Target
  def initialize(count)
    @count = count
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
    list = base.battler_map.map_data.data
    return self.create_free_selected_list(list)
  end

  def get_targets(base, user, target)
    return base.battler_map.get_tiles(target.grid_x, target.grid_y, :cross)
  end

  def render_cursor(s, x, y, options = {})
  end
end