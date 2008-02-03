require "yaml"

def get_hash(file, x, y, src_x, src_y, width, height, duration)
  return {"file"=>file, "x"=>x, "y"=>y, "src_x"=>src_x, "src_y"=>src_y, "width"=>width, "height"=>height, "duration"=>duration}
end

main = []
main << get_hash("magic",0,0,0,0,64,64,1).merge("se"=>"ok")
main << get_hash("magic",0,0,64,0,64,64,1)
main << get_hash("magic",0,0,128,0,64,64,1)
main << get_hash("magic",0,0,192,0,64,64,1)
main << get_hash("magic",0,0,64,64,64,64,1)
main << get_hash("magic",0,0,128,64,64,64,1)
main << get_hash("magic",0,0,192,64,64,64,1)
main << get_hash("magic",0,0,64,128,64,64,1)
main << get_hash("magic",0,0,128,128,64,64,1)
main << get_hash("magic",0,0,192,128,64,64,1)
main << get_hash("magic",0,0,64,192,64,64,1)
main << get_hash("magic",0,0,128,192,64,64,1)
main << get_hash("magic",0,0,192,192,64,64,1)

p main[0]["width"]
yaml = main.to_yaml

File.open("test/test.txt", "w+") do |f|
  f.write(yaml)
end