require "scenes/battle/targets/target"
class BattlerCrossTarget < Target
  def initialize(count)
    @count = count
  end

  def get_casting_targets(base, user, targets)
    arr = []
    t = base.battler_map.get_tiles(targets[0].grid_x, targets[0].grid_y, :cross)
    arr.push(targets[0])
    t.each do |obj|
      unless obj.get_unit == targets[0] || obj.get_unit.nil?
        arr.push(obj.get_unit)
      end
    end
    return arr
  end

  def get_effect_targets(base, user, targets)
    t = base.battler_map.get_tiles(targets[0].grid_x, targets[0].grid_y, :cross)
    t.delete(targets[0])
    t.push(targets[0])
    return t
  end

  def get_selectable_targets(base, user, selected_targets)
    return self.create_free_selected_list(base.battler_list - selected_targets)
  end

  def get_targets(base, user, target)
    return [target] + base.battler_map.get_tiles(target.grid_x, target.grid_y, :cross)
  end

  def render_cursor(s, x, y, options = {})
    super(s, x, y, :one, options[:target])
  end
end