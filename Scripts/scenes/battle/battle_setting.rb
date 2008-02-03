require  "scenes/battle/background"
require  "scenes/battle/battler"
require  "scenes/battle/battler_map"
require  "scenes/battle/battle_loader"
require  "scenes/battle/battle_camera"
require  "scenes/battle/enemy"
require  "scenes/battle/render_list"
require  "scenes/battle/turn_bar"
require  "lib/interval/interval_runner"
include Interval

class BattleSetting
  attr_reader :battler_list, :enemy_list, :action_list, :battler_map, :blink_counter, :command_list, :waiting_list, :skill_list
  attr_reader :render_list, :turn_bar, :battle_phase_queue, :battle_phase, :selection_phase, :camera
  attr_accessor :center_x, :center_y, :zoom, :stop, :chainable

  def initialize
    @background = Background.new
 
    @battler_list = []
    @enemy_list = []
    @skill_list = {}
    self.set_skills

    @battler_map = BattlerMap.new(self, 180, 110, 3, 3, 32, 32, 12, 0, -6, @battler_list) 
    self.set_battlers
    self.set_enemies
    @command_list = []
    @waiting_list = []
    @center_x = 0
    @center_y = 0
    @zoom = 1
    @stop = false
    @blink_counter = 0
    @blink_interval_runner = IntervalRunner.new(Interval.get_blink_interval(30, 0, 1, true){|value|@blink_counter = value})
    @chainable = false
    @turn_bar = TurnBar.new(self, -25, 2, 7, 200)
    @battle_phase = BattlePhase.new(self)
    @selection_phase = SelectionPhase.new(self)
    @battle_phase_queue = [@selection_phase, @battle_phase]
    @camera = BattleCamera.new(RenderList.new)
  end

  def render_list
    @camera.render_list
  end
  
  def unit_list
    return @battler_list + @enemy_list
  end

  def register
    self.render_list.register(@background, :bottom)
    self.render_list.register(@battler_map, :bottom)
    
    unless @battle_phase.running?
     self.render_list.register(@turn_bar, :over_top)
    end
    
    self.unit_list.each {|obj| self.render_list.register(obj, :middle, 0)}
    @selection_phase.register
  end
  
  def update
    @camera.update
    @battler_map.update
    @turn_bar.update

    self.unit_list.each do |obj|
      obj.update
      obj.clear_status_events
    end

    @blink_interval_runner.update
    @selection_phase.update(@battle_phase_queue)
    @battle_phase.update(@battle_phase_queue)
    self.register
  end

  def render(s)
    @camera.render(s)
  end

  def set_battlers
    # @battler_list << Battler.new(self, "battlers/thomas",0, 1, :thomas, @battler_map)
    # @battler_list << Battler.new(self, "battlers/elen",1, 1, :elen, @battler_map)
    # @battler_list << Battler.new(self, "battlers/michael",2, 1, :michael, @battler_map)
    # @battler_list << Battler.new(self, "battlers/halyd",1, 2, :halyd, @battler_map)
    # @battler_list << Battler.new(self, "battlers/robton",2, 0, :robton, @battler_map)
    #@battler_list << Battler.new(self, "battlers/julian",0, 1, :julian, @battler_map)
    data = {:id => "battlers/leoneed", :group => :battler, :name => "Leoneed", :grid_x => 1, :grid_y => 1, :skills => [["slash", 2],["upper_slash", 1]]}
    @battler_list << Battler.new(self, @battler_map, 0, data)
    
    data = {:id => "battlers/julian", :group => :battler, :name => "Julian", :grid_x => 0, :grid_y => 1, :skills => [["slash", 2],["upper_slash", 1]]}
    @battler_list << Battler.new(self, @battler_map, 1, data)
    #@battler_list << Battler.new(self, "battlers/fat_robin",2, 2, :fat_robin, @battler_map)
    #@battler_list << Battler.new(self, "IgohlBattle","igohl_face",2, 2, :igohl, @battler_map)
  end

  def set_enemies
    #@enemy_list << enemy = Enemy.new(self, "bird", 10, 40, "bird", :beast, 0)
    data = {:id => "enemies/bandit", :group => :enemy, :name => "Bandit", :x => 60, :y => 130, :enemy_type => :beast, :skills => [["fang", 2], ["smash", 2], ["inferno", 2], ["fire_breath", 2]]}
    @enemy_list <<  Enemy.new(self, 0, data)
  end

  def set_skills
    # @skill_list[:cure] = Skill.new(:cure, "Cure", BattlerTarget.new(1), :heal, :recover, 20)
    # @skill_list[:haste] = Skill.new(:haste, "Haste", SelfTarget.new, :support, :recover, 20)
    # @skill_list[:storm] = Skill.new(:storm, "Storm", AllEnemyTarget.new, :attack, :damage, -25)
    # @skill_list[:slash] = Skill.new(:slash, "Slash", EnemyTarget.new(1), :attack, :damage, -20)
    # @skill_list[:w_slash] = Skill.new(:w_slash, "W Slash", EnemyTarget.new(1), :attack, :damage, -40)
    # @skill_list[:cross_heal] = Skill.new(:cross_heal, "Cross Heal", CrossTileTarget.new(1) ,:heal, :recover, 30)
    # @skill_list[:armagedon] = Skill.new(:armagedon, "Armagedon", AllUnitTarget.new, :attack, :damage, -20)
    # @skill_list[:bom] = Skill.new(:bom, "Bom", UnitTarget.new(1), :attack, :damage, -100)
    # @skill_list[:comet] = Skill.new(:comet, "Comet", TileTarget.new(1), :attack, :damage, -40)
    #self.add_skill  Skill.new(:cross_heal, "Cross Heal", CrossTileTarget.new(1) ,:magic, :recover, 30, 5)
    # self.add_skill  Skill.new(:w_cure, "W Cure", BattlerTarget.new(2), :heal, :recover, 20)
    # self.add_skill  Skill.new(:self_cure, "Self Cure", SelfTarget.new, :heal, :recover, 20)
    # self.add_skill  Skill.new(:comet, "Comet", TileTarget.new(1),:magic, :damage, -40)
    # self.add_skill  Skill.new(:cross_heal, "Cross Heal", CrossTileTarget.new(1) ,:magic, :recover, 30)
    # self.add_skill  Skill.new(:drain_energy, "Drain Energy",BattlerCrossTarget.new(1),:magic, :drain, -20)
    # self.add_skill  Skill.new(:portion ,"Portion",SelfCrossTileTarget.new(1), :item, :recover, 20)
    # self.add_skill  Skill.new(:throw_knife, "Throw Knife", EnemyTarget.new(1), :item, :damage, -20)
    # self.add_skill  Skill.new(:bom, "Bom", UnitTarget.new(1),:fire, :damage, -100)
    # self.add_skill  Skill.new(:storm, "Storm", AllEnemyTarget.new,:wind, :damage, -25)
    # self.add_skill  Skill.new(:chain_lightning, "Chain Lightning",EnemyTarget.new(2),:wind, :damage, -20)
    # self.add_skill  Skill.new(:armagedon, "Armagedon", AllUnitTarget.new, :special, :damage, -20)
    # self.add_skill  Skill.new(:cure_all, "Cure All", AllBattlerTarget.new ,:magic, :recover, 20)
    # self.add_skill  Skill.new(:fire_wall, "Fire Wall", RectangleTileTarget.new(-1, 1), :magic, :damage, -10)
    # self.add_skill  Skill.new(:inferno_wall, "Inferno Wall", RectangleTileTarget.new(-1, 2), :magic, :damage, -10)
    # self.add_skill  Skill.new(:row_cure, "Row Cure", RectangleTileTarget.new(1, -1), :magic, :damage, 10)
    # self.add_skill  Skill.new(:row_heal, "Row Heal", RectangleTileTarget.new(2, -1), :magic, :damage, 10)
    # self.add_skill  Skill.new(:fire_field, "Fire Field", RectangleTileTarget.new(-1, -1), :magic, :damage, -10)
    # self.add_skill  Skill.new(:block_starvation, "Block Starvation", RectangleTileTarget.new(2, 2), :magic, :damage, -20)
    
    # @skill_list[:fang] = Skill.new(:fang, "Fang", BattlerTarget.new(1), :attack, :damage, -15, :push_back => 0)
    # @skill_list[:fire_breath] = Skill.new(:fire_breath, "Fire Breath", RectangleTileTarget.new(2, 2), :attack, :damage, -15, :push_back => 0)
    # @skill_list[:smash] = Skill.new(:smash, "Smash", BattlerTarget.new(1), :attack, :damage, -30, :push_back => 1)
    # @skill_list[:inferno] = Skill.new(:inferno, "Inferno", RectangleTileTarget.new(-1, 2), :attack, :damage, -10)
  end
end
