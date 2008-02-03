require "scenes/battle/targets/target"
class SelfTarget < Target
  def get_selectable_targets(base, user, selected_targets)
    return self.create_free_selected_list([user])
  end

  def render_cursor(s, x, y, options = {})
    super(s, x, y, :one, options[:target])
  end
end