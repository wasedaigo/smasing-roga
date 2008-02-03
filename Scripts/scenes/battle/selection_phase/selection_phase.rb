require  "d_input"
require  "scenes/battle/selection_phase/command_selection"
require "lib/interval/func"
require "lib/interval/sequence"
require "lib/interval/interval_runner"
include Interval

class SelectionPhase
  attr_accessor :selectedIndex

  def initialize(base)
    @base = base
    @seq = Sequence.new
    #@seq2 = Sequence.new
    @turn_end_later = false

    @command_menus = []
    @previous_selected_menu_index = -1
    @selected_menu_index = -1
    @selected_indexes = Array.new(8)
    @interval_runner = IntervalRunner.new
    self.turn_start
  end

  def get_available_skill_list(unit)
    list = unit.active_skill_list.dup
    @base.command_list.each do |selected_command|
      if selected_command[:action][:unit] == unit# && selected_command[:action][:command].group == :attack
        list.delete_at(selected_command[:index])
      end
    end 
    return list
  end
  
  def on_unit_removed(unit)

  end
 
  def first_item
    return @base.turn_bar.current_item
  end

  def next_turn
    arr = []
    @command_menus.each{|obj| arr << obj.close_interval}
    seq = Sequence.new(arr,
            Func.new do 
              @command_menus.clear
              @base.waiting_list.clear
              @selected_menu_index = -1
            end
          )
    @interval_runner = IntervalRunner.new(seq)
  end

  def turn_start
    unless @started
      @base.turn_bar.next(proc{self.update_title_window(self.first_item[:unit], [])})
    end
    @started = true
  end

  def turn_end(obj)
    case obj[:type]
      when :left
        if self.show_next_command_menu(obj)
          $res.play_se("cursor")
          @selected_indexes[@selected_menu_index] = obj[:value]
        end
      when :right
        if self.show_previous_command_menu
          $res.play_se("cursor")
        end
      when :cancel
        @selected_unit.posture_stack.pop
        self.next_turn
        obj[:action][:unit].discard(obj[:index]) if obj[:action][:unit].full_hand?
      when :ok
        @base.command_list.push(obj)
        @base.command_list.each do |command|
          command[:action][:targets] = obj[:action][:targets]
          command[:action][:unit].posture_stack.pop
          command[:action][:unit].posture_stack.push(:attack)
          command[:action][:unit].discard(command[:index])
        end
        command = @base.command_list.shift[:action]
        @base.battle_phase.start_action(command)
        self.update_title_window(command[:unit], [command])
        self.next_turn
      else
        raise("this must not be called")
    end
  end
  
  def show_next_command_menu(obj = nil)

    @selected_menu_index += 1
    if @selected_menu_index >= 1
    
      next_item = self.first_item
      i = 0
      
      loop do
        next_item = @base.turn_bar.items(@selected_menu_index + i - 1)
        i += 1
        if next_item.nil? || self.first_item[:unit].group != next_item[:unit].group
          @selected_menu_index -= 1
          return false
        end
        
        break if next_item[:chainable]
      end
      
      @selected_menu_index += i - 1
      @selected_unit = next_item[:unit]
    end

    @base.command_list.push(obj) unless obj.nil?
    selection_mode = :all_selectable
    
    @base.command_list.each do |command|
      selection_mode = :chain_skill_selectable
      if command[:action][:command].group != :attack
        selection_mode = :all_unselectable
        break
      end
    end
    
    @selected_unit.posture_stack.push(:pose)
    window = CommandWindow.new(200 - 28 * (@selected_menu_index), 2, @base.battle_phase, @selected_unit, self.get_available_skill_list(@selected_unit), @selected_unit.controlable?, :mode => :opened, :selection_mode => selection_mode, :selected_index => @selected_indexes[@selected_menu_index])
    
    @command_menus.push(CommandSelection.new(@base, @selected_unit, window, @selected_menu_index))
    return true
  end

  def show_previous_command_menu
    return false if @command_menus.length <= 1
    @command_menus.pop
    @selected_menu_index = @command_menus.last.no
    @selected_unit.posture_stack.pop
    @selected_unit = @base.command_list.pop[:action][:unit]
    
    #@selected_menu_index -= @previous_selected_menu_index
    return true
  end

  def update_title_window(unit, commands)
    #@title_window = CommandWindow.new(200, 2, @base.battle_phase, unit, commands, false, :mode => :opened)
  end
  
  
  def window_show_interval(time)
      Sequence.new(
        Wait.new(time),
        Func.new{@selected_unit.think(self)}
      )
  end
  
  def register
    unless @title_window.nil?
      @base.render_list.register(@title_window, :over_top) 
    end
    
    @command_menus.each do |obj|
      obj.register
      @base.render_list.register(obj, :over_top)
    end
  end
  
  def update(queue)
    @interval_runner.update

    unless @base.battle_phase.running?
      if @command_menus.empty?
        self.turn_start
        
        unless @base.turn_bar.moving?
          @selected_unit = self.first_item[:unit]
          @selected_unit.draw
          @base.turn_bar.update_turn_list(@selected_unit)
          if @selected_unit.controlable?
            self.show_next_command_menu
          else
            if @selected_unit.show_menu
              self.show_next_command_menu
              @interval_runner = IntervalRunner.new(window_show_interval(30))
            else
              @selected_unit.think(self)
            end
          end
          @started = false
        end
      else
        @command_menus.last.update do |obj|
          self.turn_end(obj)
        end
      end
    end
  end
end
