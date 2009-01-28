module SkillEquipable
  attr_reader :card_number
  def initialize_skill_equip(card_number)
    @card_number = card_number
  end
  
  def active_skill_list
    if @active_skill_list.nil?
      @active_skill_list = []
    end
    return @active_skill_list
  end
  
  def skill_list
    if @skill_list.nil?
      @skill_list = []
    end
    return @skill_list
  end
  
  def discard(index)
    self.active_skill_list.delete_at(index)
  end
  
  def draw(opened = false)
    return if self.active_skill_list.length >= @card_number
    
    list = self.skill_list.dup
    self.active_skill_list.each do |obj|
      list.delete_at(list.index(obj[:command]))
    end

    unless list.empty?
      self.active_skill_list.push({:command => list[(rand * list.size).floor], :opened => opened})
    end
  end

  def fill_hand
    (0..(@card_number - self.active_skill_list.length)).each do
      self.draw
    end
  end
  
  def full_hand?
    return self.active_skill_list.length == @card_number
  end
  
  def shuffle_skills
    self.active_skill_list.clear
    (0..(@card_number - 1)).each {self.draw(true)}
  end
end
