require "scenes/battle/targets/target"
class AllBattlerTarget < Target
  def get_casting_targets(base, user, targets)
    return base.battler_list
  end
  
  def get_selectable_targets(base, user, selected_targets = [])
    return self.create_free_selected_list(base.battler_list - selected_targets)
  end
  
  def get_targets(base, user, target)
    return base.battler_list
  end

  def render_cursor(s, x, y, options = {})
    super(s, x, y, :all, options[:targets])
  end
end