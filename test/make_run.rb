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
main << get_frame(2, [get_sprite("battlers/default",0,0,480,0,32,32)])
main << get_frame(2, [get_sprite("battlers/default",0,0,512,0,32,32)])
main << get_frame(2, [get_sprite("battlers/default",0,0,544,0,32,32)])
main << get_frame(2, [get_sprite("battlers/default",0,0,512,0,32,32)])
yaml = main.to_yaml
File.open("Data/Animations/run.csv", "w+") do |f|
  f.write(yaml)
end