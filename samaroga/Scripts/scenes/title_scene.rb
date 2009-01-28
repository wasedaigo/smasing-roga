require "scenes/transition_scene"
require "scenes/map_scene"
require "scenes/battle_scene"
require "dgo/gadgets/menu_window"

require "scenes/transitionable"
include Transitionable

class TitleScene

  def initialize
    @title_texture = $res.get_texture("Title")
    gs = Window::GRID_SIZE
    @menu_window = MenuWindow.new(gs * 7.5, gs * 10, gs * 4, gs * 3, %w(マップ バトル 終了), $font)
    @x = 0
  end

  def update stack, transition = false
    return if transition

    @menu_window.update do |index|
      case index
      when 0
        stack.push(TransitionScene.new(self, MapScene.new))
      when 1
        stack.push(TransitionScene.new(self, BattleScene.new))
      when 2
        stack.clear
      end
    end
  end

  def render(s)
    s.clear
    s.render_texture(@title_texture, 0, 0)
    @menu_window.render(s)
  end

end
