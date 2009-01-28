require "starruby"
include StarRuby

$LOAD_PATH << "./scripts/"
require  "resource_manager"
$res = ResourceManager.new("Data/anime_file.csv")
$font = Font.new("MS UI Gothic", 12)
$data_path = "."
SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

require "extension"
require "scenes/scene_stack"
require "scenes/battle_scene"
require "simple_input"

scene_stack = SceneStack.new(BattleScene.new)
#scene_stack.push(BattleScene.new)
FONT = Font.new("MS UI Gothic", 12)

#Audio.play_bgm("res/Audio/Music/battle2", :loop=>true)

def print_screen_text(str, x = 0, y = 0)
  Game.screen.render_text(str, x, y, FONT, Color.new(255, 255, 255))
end

Game.run(SCREEN_WIDTH, SCREEN_HEIGHT, :window_scale => 2, :title => "SmasingRoga", :fps => 30) do |game|
  current_scene = scene_stack.current
  if current_scene
    current_scene.update(scene_stack)
    current_scene.render(game.screen)
  else
    game.terminate
  end
  
  if SimpleInput.pressed?(:d)
    game.fps = 3000
  else
    game.fps = 30
  end
  
  game.screen.render_text(game.real_fps.to_s, 20, 20, FONT, Color.new(255, 255, 255))
end