require "starruby"
include StarRuby

require "./scripts/cursor"
require "./scripts/map"
require "./scripts/unit"

DEFAULT_FONT = Font.new("Arial", 12)

SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

Game.title = "Theme RPG"
Game.fps = 3000


map = Map.new
$cursor = Cursor.new(map)
unit = Unit.new(100, 100)


#Audio.play_bgm("Data/Audio/Music/battle2", :loop=>true)

Game.run(SCREEN_WIDTH, SCREEN_HEIGHT, :window_scale => 2) do
  Game.screen.clear

  map.update
  unit.update
  
  map.render(Game.screen)
  unit.render(Game.screen)
  $cursor.render(Game.screen)
  
  Game.screen.render_text(Game.real_fps.to_s, 20, 20, DEFAULT_FONT, Color.new(255, 255, 255))
end