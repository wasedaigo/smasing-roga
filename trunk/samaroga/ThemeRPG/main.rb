require "starruby"
include StarRuby

require "./scripts/cursor"
require "./scripts/map"
require "./scripts/unit"

DEFAULT_FONT = Font.new("Arial", 12)

SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

Game.title = "Theme RPG"
Game.fps = 30


map = Map.new
$cursor = Cursor.new(map)
unit = Unit.new(100, 100)


#Audio.play_bgm("Data/Audio/Music/battle2", :loop=>true)

Game.run(SCREEN_WIDTH, SCREEN_HEIGHT, :window_scale => 2) do |game|
  game.screen.clear

  x, y = Input.mouse_location

  map.update
  unit.update
  
  map.render(game.screen)
  unit.render(game.screen, map.scroll_x, map.scroll_y)
  $cursor.render(game.screen)
  
  game.screen.render_text(game.real_fps.to_s, 20, 20, DEFAULT_FONT, Color.new(255, 255, 255))
end