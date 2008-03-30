class Tile
  TOP_LEFT = 1
  TOP_RIGHT = 2
  BOTTOM_RIGHT = 4
  BOTTOM_LEFT = 8

  attr_reader :type, :priority
  def initialize(map, type, x, y)
    @type = type
    @map = map
    @texture = Texture.load("./data/images/map/tile")
    @dir_x = 1
    @dir_y = 1
    @no = 6
    @x = x
    @y = y
    @draw_x = 0 - @x * (@map.grid_width / 2) + @y * (@map.grid_width / 2)
    @draw_y = @x * (@map.grid_height / 2) + @y * (@map.grid_height / 2)
    @adds = []
  end

  def same_tile?(x, y)
    if @map.tiles.exists?(x, y)
      return true if @map.tiles[@x, @y].type == @type
    end
    return false
  end
  
  def update
    def check_top
      @adds << :top unless self.same_tile?(@x - 1,@y - 1)
    end
    def check_right
      @adds << :right unless self.same_tile?(@x - 1,@y + 1)
    end
    def check_bottom
      @adds << :bottom unless self.same_tile?(@x + 1,@y + 1)
    end
    def check_left
      @adds << :left unless self.same_tile?(@x + 1,@y - 1)
    end
    
    @priority = 0
    dir = 0

    dir += TOP_RIGHT if self.same_tile?(@x - 1,@y)
    dir += BOTTOM_LEFT if self.same_tile?(@x + 1,@y)
    dir += TOP_LEFT if self.same_tile?(@x,@y - 1)
    dir += BOTTOM_RIGHT if self.same_tile?(@x,@y + 1)
    
    @adds.clear
    @dir_x = 1
    @dir_y = 1

    case dir
      when TOP_LEFT
        @no = 5
        @dir_y = -1
      when TOP_RIGHT
        @no = 5
        @dir_x = -1
        @dir_y = -1
      when BOTTOM_RIGHT
        @no = 5
        @dir_x = -1
      when BOTTOM_LEFT
        @no = 5
      when TOP_LEFT | TOP_RIGHT
        @no = 2
        @dir_y = -1
        check_top
      when BOTTOM_RIGHT | BOTTOM_LEFT
        @no = 2
        check_bottom
      when TOP_LEFT | BOTTOM_RIGHT
        @no = 4
        @dir_x = -1
      when TOP_LEFT | BOTTOM_LEFT
        @no = 3
        check_left
      when TOP_RIGHT | BOTTOM_RIGHT
        @no = 3
        @dir_x = -1
        check_right
      when TOP_RIGHT | BOTTOM_LEFT
        @no = 4
      when TOP_LEFT | TOP_RIGHT | BOTTOM_RIGHT
        @no = 1
        @dir_y = -1
        check_right
        check_top
      when TOP_LEFT | TOP_RIGHT | BOTTOM_LEFT
        @no = 1
        @dir_x = -1
        @dir_y = -1
        check_left
        check_top
      when TOP_LEFT | BOTTOM_RIGHT | BOTTOM_LEFT
        @no = 1
        @dir_x = -1 
        check_left
        check_bottom
      when TOP_RIGHT | BOTTOM_RIGHT | BOTTOM_LEFT
        @no = 1
        check_right
        check_bottom
      when TOP_LEFT | TOP_RIGHT | BOTTOM_RIGHT | BOTTOM_LEFT
        @no = 0
        check_top
        check_right
        check_bottom
        check_left
      else
        @no = 6
    end

    return @adds
  end
  
  def render(s, dx, dy)
    s.render_texture(
      @texture, 
      @draw_x + dx, 
      @draw_y + dy, 
      :src_width => @map.grid_width, 
      :src_height => @map.grid_height, 
      :src_x => @no * @map.grid_width, 
      :scale_x => @dir_x, 
      :scale_y => @dir_y,
      :center_x => @map.grid_width / 2,
      :center_y => @map.grid_height / 2
    )
  end
  
  def render_adds(s, dx, dy)
    @adds.each do |item|
      case item
        when :top
          s.render_texture(
            @texture, 
            @draw_x + dx + 14, 
            @draw_y + dy, 
            :src_width => 4, 
            :src_height => 2, 
            :src_x => 7 * @map.grid_width + 14
          )
        when :right
          s.render_texture(
            @texture, 
            @draw_x + dx + 30, 
            @draw_y + dy + 6, 
            :src_width => 2, 
            :src_height => 4, 
            :src_x => 7 * @map.grid_width + 30,
            :src_y => 6
          )
        when :bottom
          s.render_texture(
            @texture, 
            @draw_x + dx + 14, 
            @draw_y + dy + 14, 
            :src_width => 4, 
            :src_height => 2, 
            :src_x => 7 * @map.grid_width + 14,
            :src_y => 14
          )
        when :left
          s.render_texture(
            @texture, 
            @draw_x + dx, 
            @draw_y + dy + 6, 
            :src_width => 2, 
            :src_height => 4, 
            :src_x => 7 * @map.grid_width,
            :src_y => 6
          )
      end
    end
  end
end