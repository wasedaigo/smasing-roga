class Frame
    attr_reader :width, :height

    def initialize
      @width = 1
      @height = 1
    end
    
    def set_size(w, h)
      @width = w
      @height = h
    end
    
    def select_frame(grid_size)
      unless @w == self.width && @h == self.height
        @w = self.width
        @h = self.height
        
        tw = self.width * grid_size
        th = self.height * grid_size

        @select_frame = Texture.new(tw, th)
        @select_frame.fill_rect(0, 0, tw, th, Color.new(0, 0, 0, 255))
        @select_frame.fill_rect(1, 1, tw - 2, th - 2, Color.new(200, 200, 0, 255))
        @select_frame.fill_rect(2, 2, tw - 4, th - 4, Color.new(0, 0, 0, 255))
        @select_frame.fill_rect(3, 3, tw - 6, th - 6, Color.new(0, 0, 0, 0))
      end
      return @select_frame
    end

    def render(s, grid_size, x, y, dx = 0, dy = 0)
      s.render_texture(
        self.select_frame(grid_size), 
        x * grid_size - dx, 
        y * grid_size - dy, 
        :alpha => 150
      )
    end
end
