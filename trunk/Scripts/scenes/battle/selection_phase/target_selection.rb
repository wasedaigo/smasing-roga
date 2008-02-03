require "d_input"
require "scenes/battle/battle_lib"

class TargetSelection
  def initialize(base, battler, target, selected_targets = [])
    @battler = battler
    @base = base

    @selected_index_x = 0
    @selected_index_y = 0
    @leftIndex = 0

    @target = target
    @targets = selected_targets
    @selected = false
    @next_target = nil

    @selected_list = @target.get_selectable_targets(@base, @battler, @targets)

    @target.get_selecting_targets(@base, @battler, @targets).each{|obj|obj.select_state = :selecting}
  end

  def move_cursor_vertically
    [:down, :up].each do |key|
      tx = 0
      ty = 0
      ty = 1 if DInput.pressed_newly?(:down)
      ty = -1 if DInput.pressed_newly?(:up)

      if (ty != 0)
        # if (@selected_index_y + ty >= self.selected_row.length) and (@selected_index_x < @selected_list.length-1)
          # tx = 1
          # ty = -9999
        # else
          # if (@selected_index_y + ty < 0) and (@selected_index_x > 0)
            # tx = -1
            # ty = 9999
          # end
        # end
        return {:x => @selected_index_x + tx, :y => @selected_index_y + ty}
      end
    end
    return nil
  end

  def move_cursor_horizonally
    [:right, :left].each do |key|
      tx = 0
      ty = 0
      tx = 1 if DInput.pressed_newly?(:right)
      tx = -1 if DInput.pressed_newly?(:left)
      if (tx != 0)
        return {:x => @selected_index_x + tx, :y => @selected_index_y + ty}
      end
    end
    return nil
  end

  def move_cursor
    index_x = @selected_index_x
    index_y = @selected_index_y

    data = move_cursor_vertically
    data = move_cursor_horizonally if data.nil?

    unless data.nil?
      tx = @selected_index_x
      ty = @selected_index_y
      @selected_index_x = ([[data[:x], @selected_list.length - 1].min, 0].max)
      @selected_index_y = ([[data[:y], self.selected_row.length - 1].min, 0].max)
      $res.play_se("cursor") unless tx == @selected_index_x && ty == @selected_index_y
    end

    return ((index_x != @selected_index_x) or (index_y != @selected_index_y))
  end

  def selected_row
    return @selected_list[@selected_index_x]
  end

  def selected_item
    return self.selected_row.nil? ? nil : self.selected_row[@selected_index_y]
  end

  def choose_command
    raise("nothing is selected") if self.selected_item.nil?
    @selected = true
    @targets.push(@target.get_selected_target(@base, @battler, self.selected_item)) unless self.selected_item.nil?

    unless @target.get_next_target.nil?
      @next_target = TargetSelection.new(@base, @battler, @target.get_next_target, @targets)
    end
  end

  def close
    self.clear
  end

  def clear
    @base.battler_map.reset_tiles
    @target.get_selecting_targets(@base, @battler, @targets).each do |obj| 
      obj.selected = false
      obj.select_state = :none
    end
    @targets.each do |obj|
      obj.selected = false
      obj.select_state = :none
    end
  end
  
  def reset
    self.clear
    @target.get_selecting_targets(@base, @battler, @targets).each do |obj| 
      obj.selected = false
      obj.select_state = :selecting
    end
    @target.get_targets(@base, @battler, self.selected_item).each do |obj|
      obj.selected = true
    end
    @targets.each do |obj|
      obj.selected = true
    end
  end

  def update
    if @type == :field
      self.choose_command
      yield @targets
      return
    end

    raise "no target to choose" if @selected_list.empty?

    unless @next_target.nil?
      self.update_next_target
    else

      if @selected
        yield @targets
        self.close
        return
      end

      if DInput.pressed_newly? :ok
        $res.play_se("ok")
        self.choose_command
        self.reset
        return
      end

      if DInput.pressed_newly? :cancel
        $res.play_se("cancel")
        self.close
        yield :cancel
        return
      end
      self.move_cursor 
      self.reset
    end
  end

  def update_next_target
    @next_target.update do |obj|
      @next_target = nil
      if obj == :cancel
        @targets.pop
        @selected = false
      else
        @targets = obj
      end
      self.reset
    end
  end
  
  def render(s, x, y)
    return if @selected_list.empty?
    @target.render_cursor(s, x, y, :target => self.selected_item, :targets => @selected_list)
    @next_target.render(s) unless @next_target.nil?
  end
end
