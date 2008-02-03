require  "scenes/battle/battle_phase/battle_phase"
require  "scenes/battle/selection_phase/selection_phase"
require  "scenes/battle/battle_setting"
require  "scenes/transitionable"
require  "d_input"

class BattleScene
  include Transitionable

  def initialize
    @battle_setting = BattleSetting.new
    @battle_setting.update
  end

  def update(stack, transition = false)
    return if transition

    @battle_setting.update
  end

  def render(s)
    s.clear
    @battle_setting.render(s)
  end
end
