require  "scenes/battle/battle_lib"

class BattlerTile
  attr_reader :selected, :grid_x, :grid_y
  attr_accessor :selected, :select_state, :alpha

  def initialize(base, battle_map, grid_x, grid_y, grid_width, grid_height)
    @base = base
    @battle_map = battle_map
    @grid_x = grid_x
    @grid_y = grid_y
    @grid_width = grid_width
    @selected = false
    @grid_height = grid_height
    @select_state = :none
    @alpha = 255
  end

  def x
    return @grid_x * @grid_width + @battle_map.x
  end

  def y
    return @grid_y * @grid_height + @battle_map.y
  end

  def height
    return @grid_height
  end

  def width
    return @grid_width
  end

  def get_unit
    if @battle_map.exists?(@grid_x, @grid_y)
      return @battle_map.get_unit(@grid_x, @grid_y)
    else
      return nil
    end
  end

  def render(s, texture, x, y)
    if @selected
      self.render_selected(s, texture, x, y)
    else
      case @select_state
        when :selecting
          self.render_selecting(s, texture, x, y)
      end
    end
  end
  
  def render_selected(s, texture, x, y)
    s.render_texture(texture, x + self.x, y + self.y, {:alpha => BattleLib.get_blink_alpha(@base.blink_counter)}.merge(BattleLib.get_blink_tone(@base.blink_counter, :red)))
  end
  
  def render_selecting(s, texture, x, y)
    s.render_texture(texture, x + self.x, y + self.y, {:alpha => BattleLib.get_blink_alpha(@base.blink_counter)}.merge(BattleLib.get_blink_tone(@base.blink_counter,:white)))
  end
end
