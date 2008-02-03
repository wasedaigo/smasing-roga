require "yaml"

def get_sprite(id, x, y, src_x, src_y, width, height, options = {})
  t = {"id"=>id, "x"=>x, "y"=>y, "src_x"=>src_x, "src_y"=>src_y, "width"=>width, "height"=>height}.merge(options)
  return t
end

def get_frame(duration, sprites=[], effects=[])
  options = {}
  options["duration"] = duration
  options["sprites"] = sprites unless sprites.empty?
  options["effects"] = effects unless effects.empty?
  return options
end

main = []
main << get_frame(2, [get_sprite("heavy_sword",32,28,128,0,32,32, "angle"=>180), get_sprite("battlers/default",0,0,288,0,32,32)])
main << get_frame(1, [get_sprite("heavy_sword",32,-4,192,0,32,32, "angle"=>90), get_sprite("battlers/default",0,0,288,0,32,32)])
main << get_frame(1, [get_sprite("heavy_sword",-24,-4,160,0,32,32), get_sprite("battlers/default",0,0,288,0,32,32)])
main << get_frame(1, [get_sprite("heavy_sword",-24,12,128,0,32,32), get_sprite("battlers/default",0,0,288,0,32,32)])
main << get_frame(1, [get_sprite("heavy_sword",-24,12,64,0,32,32), get_sprite("battlers/default",0,0,288,0,32,32)])
main << get_frame(1, [get_sprite("heavy_sword",-24,12,96,0,32,32), get_sprite("battlers/default",0,0,288,0,32,32)])
main << get_frame(1, [get_sprite("heavy_sword",-24,12,128,0,32,32), get_sprite("battlers/default",0,0,288,0,32,32)])
main << get_frame(10, [get_sprite("heavy_sword",-24,12,32,0,32,32), get_sprite("battlers/default",0,0,288,0,32,32)])

yaml = main.to_yaml

File.open("Data/Animations/heavy_sword1.csv", "w+") do |f|
  f.write(yaml)
end