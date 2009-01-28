require "scenes/battle/targets/target"
class BattlerTarget < Target
  def initialize(count)
    @count = count
  end

  def get_next_target
    return nil if @count <= 1
    return BattlerTarget.new(@count - 1)
  end

  def get_selectable_targets(base, user, selected_targets)
    return self.create_free_selected_list(base.battler_list - selected_targets)
  end

  def render_cursor(s, x, y, options = {})
    super(s,  x, y, :one, options[:target])
  end
end