require "./scripts/d_input"
require "./scripts/tile"
require "./scripts/interval/interval_runner"
require "./scripts/interval/lerp"
require "./scripts/interval/func"
require "./scripts/interval/parallel"
require "./scripts/interval/sequence"

class Map
  attr_reader :tile_x_count, :tile_y_count, :center, :grid_width, :grid_height, :tiles
  attr_reader :scroll_x, :scroll_y
  attr_accessor :scroll_tile_x, :scroll_tile_y
  
  SCROLL_MOUSE_DELTA = 20
  
  def initialize
    @base_texture = Texture.load("./data/images/map/base")
    @texture = Texture.load("./data/images/map/tile")
    
    @off_screen = Texture.new(320, 240)
    
    @tile_x_count = 20
    @tile_y_count = 20
    @center = ((@tile_x_count - 1) / 2 + 1)
    @grid_width = 32
    @grid_height = 16

    @tiles = Table.new(@tile_x_count, @tile_y_count)
    @tiles[0, 0] = Tile.new(self, 0, 0, 0)
    @tiles[0, 1] = Tile.new(self, 0, 0, 1)
    @tiles[0, 2] = Tile.new(self, 0, 0 ,2)
    
    @scroll_tile_x = 0
    @scroll_tile_y = 0
    @scroll_x = 0
    @scroll_y = 0
    
    @interval_runner = Interval::IntervalRunner.new
  end

  def abs_to_isometric_x(x, y)
    return x * @grid_width / 2 -y * @grid_width / 2
  end
  
  def abs_to_isometric_y(x, y)
    return -x * @grid_height / 2 - y * @grid_height / 2
  end
  
  def scroll_interval(time, x, y)
    x += @scroll_tile_x
    y += @scroll_tile_y
    Interval::Sequence.new(
      Interval::Parallel.new(
        Interval::Lerp.new(time, self.scroll_x, self.abs_to_isometric_x(x, y)) do |value|
          @scroll_x = value
        end,
        Interval::Lerp.new(time, self.scroll_y, self.abs_to_isometric_y(x, y))do |value|
          @scroll_y = value
        end
      ),
      Interval::Func.new do
        @scroll_tile_x = x
        @scroll_tile_y = y
      end
    )
  end
  
  def scroll
    @interval_runner.update unless @interval_runner.done?
    return unless @interval_runner.done?

    tx = 0
    ty = 0
    x, y = Input.mouse_location
    
    #  left
    if x < SCROLL_MOUSE_DELTA
      tx = 1
      ty = -1
    end
    
    # right
    if x > 320 - SCROLL_MOUSE_DELTA
      tx = -1
      ty = 1
    end

    # up
    if y < SCROLL_MOUSE_DELTA
      tx = -1
      ty = -1
    end
    
    # down
    if y > 240 - SCROLL_MOUSE_DELTA
      tx = 1
      ty = 1
    end
    
    # left up
    if x < SCROLL_MOUSE_DELTA && y < SCROLL_MOUSE_DELTA
      tx = 0
      ty = -1
    end
    
    # right down
    if x > 320 - SCROLL_MOUSE_DELTA && y > 240 - SCROLL_MOUSE_DELTA
      tx = 0
      ty = 1
    end
    
    # left down
    if x < SCROLL_MOUSE_DELTA && y > 240 - SCROLL_MOUSE_DELTA
      tx = 1
      ty = 0
    end
    
    # right up
    if x > 320 - SCROLL_MOUSE_DELTA && y < SCROLL_MOUSE_DELTA
      tx = -1
      ty = 0
    end

    p @scroll_tile_x, @scroll_tile_y
    
    if @scroll_tile_x + tx > @tile_x_count
      tx = 0
      ty = 0
    end
    if @scroll_tile_y + ty > @tile_y_count
      tx = 0
      ty = 0
    end
    if @scroll_tile_x + tx < -@tile_x_count
      tx = 0
      ty = 0
    end
    if @scroll_tile_y + ty < -10
      tx = 0
      ty = 0
    end
    
    if tx != 0 || ty != 0
      @interval_runner = Interval::IntervalRunner.new(self.scroll_interval(3, tx, ty)) 
    end
  end
  
  def update_tiles_around(x, y)
    ((x - 1)..(x + 1)).each do |i|
      ((y - 1)..(y + 1)).each do |j|
        @tiles[i, j].update if @tiles.exists?(i, j)
      end
    end
  end
  
  def update
    x, y = Input.mouse_location
    x, y = $cursor.isometric_mouse_location(x + @grid_width * @center, y)
    
    x = x + @scroll_tile_x
    y = y + @scroll_tile_y
    
    if @tiles.has_cell?(x, y)
      if DInput.pressed?(:left, :mouse)
        @tiles[x, y] = Tile.new(self, 0, x, y) 
        self.update_tiles_around(x, y)
      end
      
      if DInput.pressed?(:right, :mouse)
        @tiles[x, y] = nil 
        self.update_tiles_around(x, y)
      end
    end
    
    self.scroll
    
    tiles = @tiles.data.select{|item| item != nil}
    @off_screen.fill(StarRuby::Color.new(0, 255, 0, 255))

    tiles.each {|item|item.render(@off_screen, self.scroll_x, self.scroll_y)}
    tiles.each {|item|item.render_adds(@off_screen, self.scroll_x, self.scroll_y)}
  end

  def render(s)
    s.render_texture(@off_screen, 0, 0)
  end
end