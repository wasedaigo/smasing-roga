require "yaml"

hash = {}
hash["name"] = "Leoneed"
hash["max_hp"] = 120

arr = []
arr << "slash"
hash["skills"] = arr
yaml = hash.to_yaml

File.open("Data/battle/battler/leoneed.yaml", "w+") do |f|
  f.write(yaml)
end