require "yaml"

hash = {}
hash["name"] = "Slash"
hash["type"] = "attack"
hash["target"] = {"type" => "EnemyTarget", "args" => [1]}
hash["options"] = {:effect_value => -16, :chain_frame => 16, :chain_time => 10}
yaml = hash.to_yaml

File.open("Data/battle/skills/slash.yaml", "w+"){|f| f.write(yaml)}
hash = {}
hash["name"] = "UpperSlash"
hash["type"] = "attack"
hash["target"] = {"type" => "EnemyTarget", "args" => [1]}
hash["options"] = {:effect_value => -16, :chain_frame => 30, :chain_time => 10}
yaml = hash.to_yaml

File.open("Data/battle/skills/upper_slash.yaml", "w+"){|f| f.write(yaml)}


hash = {}
hash["name"] = "Fang"
hash["type"] = "attack"
hash["target"] = {"type" => "BattlerTarget", "args" => [1]}
hash["options"] = {:effect_value => -6}
yaml = hash.to_yaml

File.open("Data/battle/skills/fang.yaml", "w+"){|f| f.write(yaml)}

hash = {}
hash["name"] = "Smash"
hash["type"] = "attack"
hash["target"] = {"type" => "BattlerTarget", "args" => [1]}
hash["options"] = {:push_back => 1, :effect_value => -26}
yaml = hash.to_yaml

File.open("Data/battle/skills/smash.yaml", "w+"){|f| f.write(yaml)}


hash = {}
hash["name"] = "Inferno"
hash["type"] = "attack"
hash["target"] = {"type" => "RectangleTileTarget", "args" => [-1, 2]}
hash["options"] = {:effect_value => -8}
yaml = hash.to_yaml

File.open("Data/battle/skills/inferno.yaml", "w+"){|f| f.write(yaml)}

hash = {}
hash["name"] = "Fire Breath"
hash["type"] = "attack"
hash["target"] = {"type" => "RectangleTileTarget", "args" => [2, 2]}
hash["options"] = {:effect_value => -9}
yaml = hash.to_yaml

File.open("Data/battle/skills/fire_breath.yaml", "w+"){|f| f.write(yaml)}