require "scenes/battle/targets/target"
class AllEnemyTarget < Target
  def get_casting_targets(base, user, targets)
    return base.enemy_list
  end
  
  def get_selectable_targets(base, user, selected_targets = [])
    return self.create_free_selected_list(base.enemy_list - selected_targets)
  end
  
  def get_targets(base, user, target)
    return base.enemy_list
  end

  def render_cursor(s, x, y, options = {})
    super(s, x, y, :all, options[:targets])
  end
end