Sequence.new(
  camera.get_focus_interval(6, 1.0),
  Parallel.new(
    Parallel.new(
      BattleLib.get_animation_interval("magic_invocation", target, render_list),
      target.damage_interval
    )
  ),
  user.reset_animation
)