require "scenes/battle/skills/skill"
require  "scenes/battle/targets/battler_target"
require  "scenes/battle/targets/enemy_target"
require  "scenes/battle/targets/unit_target"
require  "scenes/battle/targets/self_target"
require  "scenes/battle/targets/tile_target"
require  "scenes/battle/targets/cross_tile_target"
require  "scenes/battle/targets/battler_cross_target"
require  "scenes/battle/targets/self_cross_tile_target"
require  "scenes/battle/targets/all_enemy_target"
require  "scenes/battle/targets/all_battler_target"
require  "scenes/battle/targets/all_unit_target"
require  "scenes/battle/targets/rectangle_tile_target"
require "yaml"

class SkillLoader
   def self.load_skill(id, filename)
    str = ""
    File.open(filename, "r") {|f| str = f.read}
    skill = YAML::load(str)

    case skill["target"]["type"]
    when "BattlerTarget"
      target = BattlerTarget.new(skill["target"]["args"][0])
    when "EnemyTarget"
      target = EnemyTarget.new(skill["target"]["args"][0])
    when "RectangleTileTarget"
      target = RectangleTileTarget.new(skill["target"]["args"][0], skill["target"]["args"][1])
    else
      raise("this must not be called")
    end
    
    options = {}
    unless skill["options"].nil?
      options = skill["options"]
    end
    Skill.new(id, skill["name"], target, skill["type"].intern, options)
  end
end