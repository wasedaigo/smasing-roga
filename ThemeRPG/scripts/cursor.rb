require "./scripts/unit"
require "./scripts/d_input"
class Cursor
  def initialize(map)
    @texture = Texture.load("./data/images/etc/grid")
    @cursor_texture = Texture.load("./data/images/etc/cursor")
    @mx = 0
    @my = 0
    @map = map

  end

  def detailed_tile_location(x, y)
    tx = 0
    ty = 0
    ttx = x % @map.grid_width
    tty = -1 * (y % @map.grid_height)
    
    tx = -1 if (2 * tty + ttx - @map.grid_width / 2) > 0
    tx = 1 if (2 * tty + ttx + @map.grid_height) < 0
    
    ty = -1 if (2 * tty - ttx + @map.grid_height) > 0
    ty = 1 if (2 * tty - ttx + 2 * @map.grid_height + @map.grid_width / 2) < 0
    
    return tx, ty
  end
  
  def convert_screen_coordinate_to_isometric_coordinate(x, y)
    tx = x
    ty = y - x.abs

    if tx < 0
      return -2 * tx + ty, ty
    else
      return ty, 2 * tx + ty
    end
  end
  
  def isometric_mouse_location
    
    x, y = Input.mouse_location

    dx, dy = self.detailed_tile_location(x, y)

    tx, ty = self.convert_screen_coordinate_to_isometric_coordinate((x / @map.grid_width) - @map.center, (y / @map.grid_height))

    #p "x: #{x} tx: #{tx}, ty: #{ty} dx: #{dx} dy: #{dy}"
    return tx + dx, ty + dy
  end
  
  def update
  end

  def render(s)
    x, y = self.isometric_mouse_location
    s.render_texture(@texture, @map.center * @map.grid_width - x * (@map.grid_width / 2) + y * (@map.grid_width / 2) , x * (@map.grid_height/2) + y * (@map.grid_height/2))
    
    x, y = Input.mouse_location
    s.render_texture(@cursor_texture, x - 4, y - 4)
  end
end