class Window
  GRID_SIZE = 16
  FONT = Font.new "MS UI Gothic", 12

  attr_reader :width, :height
  attr_reader :content_texture
  attr_accessor :x, :y, :visible
  def initialize(x, y, width, height, texture)
    @x = x
    @y = y

    @width = [(width / GRID_SIZE.to_f).ceil * GRID_SIZE, GRID_SIZE].max + GRID_SIZE
    @height = [(height / GRID_SIZE.to_f).ceil * GRID_SIZE, GRID_SIZE].max + GRID_SIZE

    @texture = texture
    @visible = true
  end

  def content_texture
    if @content_texture.nil?
      @content_texture = Texture.new(@width - GRID_SIZE, @height - GRID_SIZE)
    end
    @content_texture
  end

  def frame_texture
    if @frame_texture.nil?
      half = GRID_SIZE / 2
      @frame_texture = Texture.new(@width, @height)

      last_i = @width / GRID_SIZE
      last_j = @height / GRID_SIZE

      (0..last_j).each do |j|
        (0..last_i).each do |i|

          case i
          when 0
            src_x     = 0
            src_width = half
          when last_i
            src_x     = half * 3
            src_width = half
          else
            src_x     = half
            src_width = GRID_SIZE
          end

          case j
          when 0
            src_y      = 0
            src_height = half
          when last_j
            src_y      = half * 3
            src_height = half
          else
            src_y      = half
            src_height = GRID_SIZE
          end

          x = [i * GRID_SIZE - half, 0].max
          y = [j * GRID_SIZE - half, 0].max
          @frame_texture.render_texture(@texture, x, y, :src_x => src_x, :src_y => src_y, :src_width => src_width, :src_height => src_height)
        end
      end
    end
    @frame_texture
  end

  def render(s, x = 0, y = 0, options = {})
    s.render_texture(frame_texture, x + @x, y + @y, options)
    s.render_texture(content_texture, x + @x + GRID_SIZE / 2, y + @y + GRID_SIZE / 2, options)
  end
end
