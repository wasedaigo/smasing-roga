Sequence.new(
  Func.new{user.visible = false},
  Parallel.new(
    camera.get_focus_interval(10, 1.5, target),
    user.walk_interval(10, target.right, target.bottom - user.height, 0)
  ),
  BattleLib.get_animation_interval("heavy_sword1", user, render_list, {:swap_textures=>[{:from_id=>"battlers/default", :to_id=>"#{user.id}"}]}),
  Func.new{user.visible = true},
  
  Parallel.new(
    target.move_z_interval(10, target.z + 120),
    camera.get_focus_interval(10, 1.5, target),
    user.jump_interval2(5, 10, user.z + 140)
  ),

  Parallel.new(
    Sequence.new(
      Func.new{user.visible = false},
      Parallel.new(
        BattleLib.get_animation_interval("heavy_sword1", user, render_list, {:swap_textures=>[{:from_id=>"battlers/default", :to_id=>"#{user.id}"}]}),
        BattleLib.get_animation_interval("magic_invocation", target, render_list),
        target.damage_interval
      ),
      Func.new{user.visible = true},
      user.move_z_interval(2, user.z + 150),
      user.move_z_interval(15, user.z)
    ),
    Sequence.new(
      Wait.new(10),
      Parallel.new(
        target.move_z_interval(5, target.z),
        camera.get_focus_interval(5, 1.5, target),
        Loop.new(-1, target.rotation_interval(5))
      )
    )
  ),
  user.back_interval(target),
  Func.new{user.reset_animation}
)