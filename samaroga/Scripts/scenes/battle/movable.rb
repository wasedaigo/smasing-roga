module Movable
  attr_reader :movable_distance
  def setup_movability(movable_distance)
    @movable_distance = movable_distance
    self.reset_movement
  end

  def reset_movement
    @moved_distance_x = 0
    @moved_distance_y = 0
  end

  def moved_distance
    return @moved_distance_x.abs + @moved_distance_y.abs
  end

  def get_push_back_interval(time, direction, value)
    dx = 0
    dy = 0
    case direction
    when :up
      dy = -value
    when :right
      dx = value
    when :down
      dy = value
    when :left
      dx = -value
    else
      raise "must not be called"
    end

    if @grid_x + dx < 0
      dx = -@grid_x   
    end    
    if @grid_x + dx >= @battler_map.w_count
      dx = @battler_map.w_count - @grid_x  - 1  
    end
    if @grid_y + dy < 0
      dy = -@grid_y   
    end 
    if @grid_y + dy >= @battler_map.h_count
      dy = @battler_map.h_count - @grid_y - 1  
    end
    return Sequence.new if dx == 0 && dy == 0
    return Sequence.new unless @battler_map.empty?(@grid_x + dx, @grid_y + dy)
    if dx !=0
      @grid_x += dx
      t = dx * @battler_map.grid_width
      return Lerp.new(time, 0, t){|value| @x = @base_x + value}
    end
    if dy != 0
      @grid_y += dy
      t = dy * @battler_map.grid_height
      return Lerp.new(time, 0, t){|value| @y = @base_y + value}
    end
    
    self.refresh_base
  end
  
  def get_move_interval(time, direction)
    dx = 0
    dy = 0
    case direction
    when :up
      dy = -1 if (moved_distance < @movable_distance) or (@moved_distance_y > 0)

    when :right
      dx = 1 if (moved_distance < @movable_distance) or (@moved_distance_x < 0)

    when :down
      dy = 1 if (moved_distance < @movable_distance) or (@moved_distance_y < 0)

    when :left
      dx = -1 if (moved_distance < @movable_distance) or (@moved_distance_x > 0)

    else
      raise "must not be called"
    end

    return Sequence.new unless @battler_map.empty?(@grid_x + dx, @grid_y + dy)


    if dx != 0
      @moved_distance_x += dx
      @grid_x += dx
    end
    if dy != 0
      @moved_distance_y += dy
      @grid_y += dy
    end
    
    self.refresh_base
    tx = @base_x
    ty = @base_y
    
    return  Sequence.new(
              self.crouch_interval(5), 
              self.jump_interval(10, tx, ty, 30),
              Func.new{self.reset_animation}
            )
  end
end
