Sequence.new(
  Func.new{user.visible = false},
  Parallel.new(
    camera.get_focus_interval(10, 1.5, target),
    user.walk_interval(10, target.right, target.bottom - user.height, 0)
  ),
  BattleLib.get_animation_interval("heavy_sword1", user, render_list, {:swap_textures=>[{:from_id=>"battlers/default", :to_id=>"#{user.id}"}]}),
  Func.new{user.visible = true},
  Parallel.new(
    Parallel.new(
      BattleLib.get_animation_interval("magic_invocation", target, render_list),
      target.damage_interval
    ),
    user.back_interval(target)
  ),
  Func.new{user.reset_animation}
)