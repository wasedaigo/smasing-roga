require "lib/gadgets/battle_menu_window"
require "scenes/battle/command_window"
require "scenes/battle/selection_phase/target_selection"
require "d_input"
require "scenes/battle/movable"
require "lib/interval/interval_runner"

class CommandSelection
  attr_reader :no
  def initialize(base, unit, window, no)
    @no = no
    @base = base
    @unit = unit
    @selected_index = -1
    @selectedGroup = 0
    @target_selection = nil
    @tasks = []
    @window = window
    
    if @unit.class.include?(Movable)
      @center_x = @unit.grid_x
      @center_y = @unit.grid_y
      @unit.reset_movement
    end
  end

  def close_interval
    return @window.close_interval
  end
  
  def selected_item
    return @window.selected_item
  end

  def choose_command
    if @unit.class.include?(Movable)
      if DInput.pressed?(:z)
        @base.battler_map.reset_tiles
        list = @base.battler_map.get_tiles(@center_x, @center_y, :move, :size => @unit.movable_distance)
        list.each{|obj|obj.select_state = :selecting}
        [:up, :right, :down, :left].each do |value|
          if DInput.pressed?(value)
            @tasks << IntervalRunner.new(@unit.get_move_interval(16, value))
          end
        end
        return
      else
        @base.battler_map.reset_tiles
      end
    end
    
    @window.update do |result|
      @selected_index = result[:value]
      case result[:type]
      when :ok
        $res.play_se("ok")
        @target_selection = TargetSelection.new(@base, @unit, self.selected_item.target)
      when :left, :right
        yield :type => result[:type], :index => @selected_index, :action => {:unit => @unit, :command => self.selected_item}
      when :cancel
        yield :type => result[:type], :index => @selected_index, :action => {:unit => @unit, :command => self.selected_item}
        
      else
        raise "this must not be called"
      end
    end
  end
  
  def register
    @base.render_list.register(@target_selection, :middle_top) unless @target_selection.nil?
  end

  def update
    unless @tasks.empty?
      if @tasks.last.done?
        @tasks.pop
      else
        @tasks.last.update
      end
      return
    end
    
    if @target_selection.nil?
      self.choose_command do |value| 
        yield value
        return
      end
    else
      @target_selection.update do |obj|
        @target_selection = nil
        unless obj == :cancel
          yield :type => :ok, :index => @selected_index, :action => {:unit => @unit, :command => self.selected_item, :targets => obj}
        end
      end
    end
  end

  def render(s, x, y)
    @window.render(s, x, y)
  end
end
