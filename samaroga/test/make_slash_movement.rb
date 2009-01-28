require "yaml"

def get_hash(id, x, y, src_x, src_y, width, height, duration)
  return {"id"=>id, "x"=>x, "y"=>y, "src_x"=>src_x, "src_y"=>src_y, "width"=>width, "height"=>height, "duration"=>duration}
end

main = []
main << get_hash("heavy_sword",48,32,128,0,32,32,2).merge("se"=>"ok", "angle"=>180)
main << get_hash("heavy_sword",48,0,192,0,32,32,1).merge("angle"=>90)
main << get_hash("heavy_sword",-8,0,160,0,32,32,1)
main << get_hash("heavy_sword",-8,16,128,0,32,32,1)
main << get_hash("heavy_sword",-8,16,64,0,32,32,1)
main << get_hash("heavy_sword",-8,16,96,0,32,32,1)
main << get_hash("heavy_sword",-8,16,128,0,32,32,1)
main << get_hash("heavy_sword",-8,16,32,0,32,32,10)

yaml = main.to_yaml

File.open("Data/Animations/heavy_sword1.csv", "w+") do |f|
  f.write(yaml)
end