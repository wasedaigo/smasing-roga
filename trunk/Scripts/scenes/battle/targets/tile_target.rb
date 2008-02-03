require "scenes/battle/targets/target"
class TileTarget < Target
  def initialize(count)
    @count = count
  end

  def get_casting_targets(base, user, targets)
    arr = []
    targets.each do |obj|
      arr.push(obj.get_unit) unless obj.get_unit.nil?
    end
    return arr
  end
  
  def get_effect_targets(base, user, targets)
    return targets
  end
  
  def get_selectable_targets(base, user, selected_targets)
    list = base.battler_map.map_data.data
    return self.create_free_selected_list(list)
  end

  def render_cursor(s, x, y, options = {})
    super(s, x, y, :one, options[:target])
  end
end