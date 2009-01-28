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
main << get_frame(1, [get_sprite("magic",0,0,0,0,64,64)], ["se"=>"ok"])
main << get_frame(1, [get_sprite("magic",0,0,64,0,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,128,0,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,192,0,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,64,64,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,128,64,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,192,64,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,64,128,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,128,128,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,192,128,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,64,192,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,128,192,64,64)])
main << get_frame(1, [get_sprite("magic",0,0,192,192,64,64)])

yaml = main.to_yaml

File.open("Data/Animations/magic_invocation.csv", "w+") do |f|
  f.write(yaml)
end