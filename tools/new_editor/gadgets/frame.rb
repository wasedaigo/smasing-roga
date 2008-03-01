module Frame
    def frame_w
      return (@ex - @sx).abs + 1
    end
    
    def frame_h
      return (@ey - @sy).abs + 1
    end
    
    def select_frame
      unless @frame_w == self.frame_w && @frame_h == self.frame_h
        @frame_w = self.frame_w
        @frame_h = self.frame_h
        tw = self.frame_w * SRoga::Config::GRID_SIZE
        th = self.frame_h * SRoga::Config::GRID_SIZE

        @select_frame = Texture.new(tw, th)
        @select_frame.fill_rect(0, 0, tw, th, Color.new(0, 0, 0, 255))
        @select_frame.fill_rect(1, 1, tw - 2, th - 2, Color.new(200, 200, 0, 255))
        @select_frame.fill_rect(2, 2, tw - 4, th - 4, Color.new(0, 0, 0, 255))
        @select_frame.fill_rect(3, 3, tw - 6, th - 6, Color.new(0, 0, 0, 0))
      end
      return @select_frame
    end
    
    def render_frame(s, dx = 0, dy = 0)
      s.render_texture(
        self.select_frame, 
        [@sx, @ex].min * SRoga::Config::GRID_SIZE * @frame_zoom - dx / @zoom, 
        [@sy, @ey].min * SRoga::Config::GRID_SIZE * @frame_zoom - dy / @zoom, 
        :alpha => 150, 
        :scale_x => @frame_zoom, 
        :scale_y => @frame_zoom
      )
    end
end
