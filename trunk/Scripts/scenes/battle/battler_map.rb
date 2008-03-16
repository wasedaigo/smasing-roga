require  "lib/table"
require  "lib/interval/interval_lib"
require  "scenes/battle/battler_tile"

class BattlerMap
  attr_reader :grid_width, :grid_height, :map_data, :offset_x, :offset_y, :w_count, :h_count
  attr_accessor :x, :y,:alpha, :tone

  def initialize(base, x, y, w_count, h_count, grid_width, grid_height, space, offset_x, offset_y, battler_list)
    @base = base
    @x = x
    @y = y
    @w_count = w_count
    @h_count = h_count
    @space = space
    @offset_x = offset_x
    @offset_y = offset_y
    @battler_list = battler_list
    @grid_width = grid_width + @space
    @grid_height = grid_height + @space
    @map_data = DLib::Table.new(w_count, Array.new(w_count * h_count))
    @map_data.each_with_two_index do |obj, i, j|
      @map_data[i, j] = BattlerTile.new(base, self, i, j, @grid_width, @grid_height)
    end
  end

  #  it is empty when there is no obstacle on the tile
  def empty?(x, y)
    return x >= 0 && x < @w_count && y >= 0 && y < @h_count && !self.exists?(x, y)
  end

  #  if thre is something on the tile
  def exists?(x, y)
    return !@battler_list.find{|obj| obj.grid_x == x && obj.grid_y == y}.nil?
  end

  # get area with certain distance from (0, 0)
  def get_area(size)
    raise("size must be more than 0") if size < 0
    return [[0, 0]] if size == 0
    arr = []
    (-size..size).each do |x|
      [-(size - x.abs), (size - x.abs)].uniq.each do |y|
        arr.push([x, y])
      end
    end

    return arr + get_area(size - 1)
  end

  def get_rect_area(width, height)
    raise("width and height must be more than 0") if width <= 0 || height <= 0
    arr = []
    (0..[width - 1,@w_count - 1].min).each do |i|
      (0..[height - 1,@h_count - 1].min).each do |j|
      arr.push([i, j])
      end
    end
    return arr
  end
  
  #  if thre is something on the tile
  def get_unit(x, y)
    raise "no unit exists" unless self.exists?(x, y)
    return @battler_list.find{|obj| obj.grid_x == x && obj.grid_y == y}
  end

  # get tiles depends on type
  def get_tiles(center_x, center_y, type, options = {:size => 1, :width => 1, :height => 1})
    arr = []
    case type
    when :cross
      get_area(options[:size]).each do |obj|
        tx = obj[0] + center_x
        ty = obj[1] + center_y
        arr.push(@map_data[tx, ty]) if @map_data.exists?(tx, ty)
      end
    when :one
       arr.push(@map_data[center_x, center_y]) if @map_data.exists?(center_x, center_y)
    when :rectangle
      get_rect_area(options[:width], options[:height]).each do |obj|
        tx = obj[0] + center_x
        ty = obj[1] + center_y
        arr.push(@map_data[tx, ty]) if @map_data.exists?(tx, ty)
      end
    when :move
      get_area(options[:size]).each do |obj|
        tx = obj[0] + center_x
        ty = obj[1] + center_y
        arr.push(@map_data[tx, ty]) if self.empty?(tx, ty)
      end
    else
      raise "must not be called"
    end
    return arr
  end

  def reset_tiles
    @map_data.each do |obj|
      obj.selected = false
      obj.select_state = :none
    end
  end

  def texture
    if @texture == nil
      #@texture = Texture.new @grid_width - @space, @grid_height - @space
      #@texture.fill Color.new(66,66,255,255)
      @texture = $res.get_texture("battle_tile")
    end
    return @texture
  end

  def update

  end

  def render(s, x, y)
    @map_data.each_with_two_index do |obj, i, j|
      obj.render(s, texture, x, y)
    end
  end
end
