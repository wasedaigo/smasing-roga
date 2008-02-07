require "starruby"
include StarRuby

$LOAD_PATH << "./Scripts/"
require  "resource_manager"
$res = ResourceManager.new("Data/anime_file.csv")
$font = Font.new("MS UI Gothic", 12)
$data_path = "."
SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

require  "extension"
require  "scenes/scene_stack"
require  "scenes/title_scene"
require  "scenes/battle_scene"
require  "scenes/map_scene"

Game.title = "Test Game"
Game.fps = 60
scene_stack = SceneStack.new(TitleScene.new)
scene_stack.push(BattleScene.new)
FONT = Font.new("MS UI Gothic", 12)

#Audio.play_bgm("Data/Audio/Music/battle2", :loop=>true)

def print_screen_text(str, x = 0, y = 0)
  Game.screen.render_text(str, x, y, FONT, Color.new(255, 255, 255))
end

Game.run(SCREEN_WIDTH, SCREEN_HEIGHT, :window_scale => 3) do
  current_scene = scene_stack.current
  if current_scene
    current_scene.update(scene_stack)
    current_scene.render(Game.screen)
  else
    Game.terminate
  end
  Game.screen.render_text(Game.real_fps.to_s, 20, 20, FONT, Color.new(255, 255, 255))
end