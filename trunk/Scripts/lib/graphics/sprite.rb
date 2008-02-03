module Graphics
  class Sprite
    attr_accessor :x, :y, :texture_id

    [:src_x , :src_y, :src_width, :src_height, :scale_x, :scale_y, :angle, :center_x, :center_y, :alpha, :tone].each do |key|
      define_method "#{key}=" do |arg|
        @options[key] = arg
      end
    end

    def initialize(texture, x = 0, y = 0,  options = {})
      @texture = texture
      @x = x
      @y = y
      @options = options
    end

    def height
      t1 = @options[:src_height] || @texture.height
      t2 = @options[:scale_y] || 1
      return t1 * t2
    end

    def width
      t1 = @options[:src_width] || @texture.width
      t2 = @options[:scale_x] || 1
      return t1 * t2
    end
    
    def swap_texture(texture, texture_id = nil)
      @texture = texture
      @options[:texture_id] = texture_id
    end

    def texture_id
      return @options[:texture_id]
    end
    
    def render(s, x = 0, y = 0)
      s.render_texture(@texture, @x + x, @y + y, @options)
    end
  end
end
