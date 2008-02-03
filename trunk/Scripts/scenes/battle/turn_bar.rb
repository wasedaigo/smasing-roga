require  "scenes/battle/turn_box"
require  "lib/interval/func"
require  "lib/interval/lerp"
require  "lib/interval/interval_runner"
require  "lib/interval/parallel"
require  "lib/interval/sequence"
include Interval

TIME = 5
class TurnBar
  attr_reader :current_item
  def initialize(base, x, y, count, width)
    @base = base
    @unit_list = []
    @prev_unit_list = []
    @x = x
    @y = y
    @count = count
    @width = width
    @delta = @width/count
    @first = nil
    @offset = @delta
    @turn_list = []
    
    @interval_runner = IntervalRunner.new
    @show_skill_icons = false
    
    self.update_turn_list
  end

  def chainable?(check_list, obj, last)
    unit = obj[:unit]
    t = true
    t = false if unit.active_skill_list.empty?
    t = false if obj == last
    t = false unless self.connected?(check_list, obj)
    t = false if check_list.include?(unit)
    t = false if unit.active_skill_list.length <= check_list.select{|i| i == unit}.length
    return t
  end

  def connected?(check_list, obj)
    unit = obj[:unit]
    check_list.empty? || check_list[0].group == unit.group
  end
  
  def generate_wait_time_list
    arr = []
    @base.unit_list.select{|obj|obj.actable?}.each do |obj|
      t = 0
      (0..@count).each do |value|
        if value == 0
          t = obj.wait_time
        else
          t += obj.max_time
        end
        arr.push({:unit => obj, :time => t})
      end
    end
    i = 0
    return arr.sort_by{|obj| [obj[:time], i += 1]}
  end

  def generate_turn_list(base_unit)
    check_list = []
    check_list.push(base_unit) unless base_unit.nil?
    chainable = true
    prev_unit = nil
    arr = self.generate_wait_time_list
    arr[0..@count].collect do |obj|
      t = false
      if chainable
        if self.connected?(check_list, obj)
          t = self.chainable?(check_list, obj, arr[@count])
        else
          chainable = false
          t = false
        end
      end
      
      check_list.push(obj[:unit])
      prev_unit = obj[:unit]
      {:unit => obj[:unit], :chainable => t }
    end
  end
  
  def update_turn_list(base_unit = nil)
    @turn_list = self.generate_turn_list(base_unit)
    @unit_list.clear
    @turn_list.each_with_index do |obj, i|
      @unit_list.push(TurnBox.new(obj[:unit], i))
    end
    @prev_unit_list = @unit_list.dup
  end

  def generate_interval_runneruence(proc)
    Sequence.new(
      Lerp.new(TIME, 1, @delta){|value| @offset = value},
      Func.new {self.next_turn(proc)}
    )
  end
  
  def next(proc = nil)
    return unless @interval_runner.done?
    @show_skill_icons = false
    self.update_turn_list
    @interval_runner = IntervalRunner.new(self.generate_interval_runneruence(proc))
  end
  
  def next_turn(proc)
    @current_item = @turn_list.first
    self.refresh_wait_time
    proc.call unless proc.nil?
    self.update_turn_list
    @show_skill_icons = true
    @offset = 0
  end

  def refresh_wait_time
    t = self.current_unit.wait_time
    @base.unit_list.each{|unit|unit.wait_time -= t}
    self.current_unit.reset_wait_time
  end
  
  def moving?
    return !@interval_runner.done?
  end
  
  def current_unit
    return @current_item[:unit]
  end
  
  def next_unit
    return self.items(0)[:unit]
  end
  
  def items(index)
    return nil if index >= @turn_list.length
    return @turn_list[index]
  end

  def update
     @interval_runner.update
  end

  def render(s, x, y)
    self.render_unit_icons(s, x, y)
    self.render_skill_icons(s, x, y)
  end
  
  def render_unit_icons(s, x, y)
    @unit_list.each_with_index do |obj, i|
      obj.render(s, x + @x + @offset + @width - @delta * i, y + @y)
    end
  end

  def render_skill_icons(s, x, y)
    if !self.moving? && !@unit_list.empty?
      @turn_list.each_with_index do |item, i|
        next unless item[:chainable]
        next unless item[:unit].controlable?
        @show_skill_icons = false if @base.battle_phase.running?
        if @show_skill_icons
          list = @base.selection_phase.get_available_skill_list(item[:unit])
          list.each_with_index do |skill, j|
            ICON.render_skill_icon(s, skill[:command].group, x + @x + @width + 4 - @delta * i, y + @y + 21 + 16 * j)
          end
        end
      end
    end
  end
end