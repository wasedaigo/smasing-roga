require "yaml"

module BattleLoader
   def self.load_battler(id, filename)
    str = ""
    File.open(filename, "r") {|f| str = f.read}
    battler = YAML::load(str)
    
    case skill["target"]
    when "BattlerTarget"
      target = BattlerTarget.new(skill["target"]["args"][0])
    else
      raise("this must not be called")
    end
    
    Skill.new(self, id, skill["name"], target, skill["type"].intern, -15, :push_back => 0)
  end
end