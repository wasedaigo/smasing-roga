require "./scripts/d_input"
require "./scripts/tile"

class Map
  attr_reader :tile_x_count, :tile_y_count, :center, :grid_width, :grid_height, :tiles

  def initialize
    @base_texture = Texture.load("./data/images/map/base")
    @texture = Texture.load("./data/images/map/tile")
    
    @tile_x_count = 20
    @tile_y_count = 20
    @center = ((@tile_x_count - 1) / 2 + 1)
    @grid_width = 32
    @grid_height = 16
    

    @tiles = Table.new(@tile_x_count, @tile_y_count)
    @tiles[0, 0] = Tile.new(self, 0, 0, 0)
    @tiles[0, 1] = Tile.new(self, 0, 0, 1)
    @tiles[0, 2] = Tile.new(self, 0, 0 ,2)
  end

  def update_tiles_around(x, y)
    ((x - 1)..(x + 1)).each do |i|
      ((y - 1)..(y + 1)).each do |j|
        @tiles[i, j].update if @tiles.exists?(i, j)
      end
    end
  end

  def update
    x, y = $cursor.isometric_mouse_location
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
  end

  def render(s)
    tiles = @tiles.data.select{|item| item != nil}
    s.fill(StarRuby::Color.new(0, 255, 0, 255))
    s.render_texture(@base_texture, 0, 80)

    tiles.each {|item|item.render(s)}
    tiles.each {|item|item.render_adds(s)}
  end
end