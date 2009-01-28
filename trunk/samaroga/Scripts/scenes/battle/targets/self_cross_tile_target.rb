require "scenes/battle/targets/target"
require "scenes/battle/targets/target_point"
class SelfCrossTileTarget < Target
  def initialize(count)
    @count = count
  end

  def get_casting_targets(base, user, targets)
    arr = []
    self.get_effect_targets(base, user, targets).each do |obj|
      arr.push(obj.get_unit) unless obj.get_unit.nil?
    end
    return arr
  end

  def get_effect_targets(base, user, targets)
    return base.battler_map.get_tiles(user.grid_x + targets[0].grid_x, user.grid_y + targets[0].grid_y, :one)
  end

  def get_selectable_targets(base, user, selected_targets)
    list = base.battler_map.get_tiles(user.grid_x, user.grid_y, :cross)
    return self.create_free_selected_list(list)
  end

  def get_selected_target(base, user, target)
    return TargetPoint.new(target.grid_x - user.grid_x, target.grid_y - user.grid_y)
  end
  
  def render_cursor(s, x, y, options = {})
    super(s, x, y, :one, options[:target])
  end
end