require "gadgets/frame"
require "scenes/map/config"

PALET_ROW_COUNT = 8
module Editor
  module Map
    class PaletPanel < Gtk::VBox
      attr_reader :chip_id, :chipset, :frame
      attr_accessor :zoom, :active
      
      def initialize(palet_notebook, h)
        super()
        
        @palet_notebook = palet_notebook
        
        self.set_height_request(h)
        
        @mx = -1
        @my = -1
        @sx = 0
        @sy = 0
        @ex = 0
        @ey = 0
        @zoom = 2

        @scroll_box = Editor::ScrollBox.new(1, 1, self.grid_size) do |type|
          self.render
        end
        
        @chip_id = 0
        @chipset_no = 0
        @chipset = nil
        @active = true

        @frame = Frame.new

        self.set_panel
        self.set_signals
        self.render
      end
      
      def set_signals
        @scroll_box.signal_connect("motion-notify-event") do |item, event|
          self.on_motion(event)
        end
        
        @scroll_box.signal_connect("button-press-event") do |item, event|
          case(event.button)
            when 1
              self.on_left_down(event)
            when 3
              self.on_right_down(event)
          end
        end

        @scroll_box.signal_connect("button-release-event") do |item, event|
          case(event.button)
            when 1
              self.on_left_up(event)
            when 3
              self.on_right_up(event)
          end
        end
        
        @scroll_box.signal_connect("expose_event") do
          self.render
        end
        
      end
        
      def set_panel
        self.add(@scroll_box)
      end

      #Property
      def active=(value)
        @active = value
      end
      
      def active?
        return @active
      end
      
      def grid_size
        return SRoga::Config::GRID_SIZE * @zoom
      end
      
      def grid_x
        return @chipset.w_count 
      end
      
      def grid_y
        return @chipset.h_count
      end
      
      def scroll_w_count
        return @scroll_box.h_scrollbar.value.floor
      end
      
      def scroll_h_count
        return @scroll_box.v_scrollbar.value.floor
      end
      
      def scroll_x
        return self.scroll_w_count * self.grid_size
      end
      
      def scroll_y
        return self.scroll_h_count * self.grid_size  
      end

      #Standard Method
      def select(x, y)
        return if x >= @chipset.w_count || y >= @chipset.h_count
      
        @frame.set_size(1, 1)
        @sx = x
        @sy = y
        @ex = @sx
        @ey = @sy
        
        self.render
      end
      
      def select_chip_by_no(no)
        tx1 = (no % PALET_ROW_COUNT) * self.grid_size
        ty1 = (no / PALET_ROW_COUNT) * self.grid_size

        tx2 = (tx1 / self.grid_size).floor
        ty2 = (ty1 / self.grid_size).floor

        self.select(tx2, ty2)
      end
    
      def render
        return if @chipset.nil?
        return if @scroll_box.content_image.window.nil?
        return if @scroll_box.width <= 1 || @scroll_box.height <= 1

        if(@dst_texture.nil? || (@dst_texture.width != @scroll_box.width || @dst_texture.height != @scroll_box.height))
          @dst_texture = Texture.new(@scroll_box.width, @scroll_box.height)
        end
        @dst_texture.fill(Color.new(0, 0, 0, 255))
        
        if @texture == nil || (@texture.width != (@scroll_box.width / @zoom) || @texture.height != (@scroll_box.height / @zoom))
          p "w #{@scroll_box.width} h#{@scroll_box.height} zoom#{@zoom}"
          @texture = Texture.new(@scroll_box.width / @zoom, @scroll_box.height / @zoom)
        end
        @texture.fill(Color.new(0, 0, 0, 255))
     
        @chipset.render_sample(@texture, 0, 0, :src_x => self.scroll_x / @zoom, :src_y => self.scroll_y / @zoom)
        @frame.render(@texture, self.grid_size / @zoom, [@sx, @ex].min - scroll_w_count, [@sy, @ey].min - scroll_h_count) if @active
        @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom)

        buf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @dst_texture.width, @dst_texture.height, @dst_texture.width * 3)
        area = @scroll_box.content_image
        area.window.draw_pixbuf(area.style.fg_gc(area.state), buf, 0, 0, 0, 0, @dst_texture.width, @dst_texture.height, Gdk::RGB::DITHER_NONE, 0, 0)
        p
      end

      # Events
      def on_left_down(e)
        @frame.set_size(1, 1)
        tx1 = self.scroll_x
        ty1 = self.scroll_y
        tx2 = ((e.x + self.scroll_x) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        ty2 = ((e.y + self.scroll_y )/ (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        self.select(tx2, ty2)
        @left_pressed = true
        self.active = true
        
        @palet_notebook.palets.each {|obj| obj.active = false}
        self.active = true
      end
      
      def on_left_up(e)
        @left_pressed = false
      end

      def on_right_down(e)
        @frame.set_size(1, 1)
        @right_pressed = true
      end

      def on_right_up(e)
        @frame.set_size((@ex - @sx).abs + 1, (@ey - @sy).abs + 1)
        @right_pressed = false
      end

    	def on_motion(e)
        if @left_pressed
          tx = ((e.x + self.scroll_x) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          ty = ((e.y + self.scroll_y) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          if tx >= 0 && ty >= 0 && tx < self.grid_x && ty < self.grid_y
            @ex = ((e.x + self.scroll_x) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
            @ey = ((e.y + self.scroll_y) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          end
          @frame.set_size((@ex - @sx).abs + 1, (@ey - @sy).abs + 1)
        end
        
        self.render
    	end
      
      #Iterator
      def each_chip_info
        (0 .. (@sx - @ex).abs).each do |x|
          (0 .. (@sy - @ey).abs).each do |y|
            yield @chipset.palet_chips[([@sy, @ey].min + y) * PALET_ROW_COUNT + ([@sx, @ex].min + x)], x, y
          end
        end
      end

      def on_resize(width, height)
        @scroll_box.set_size_request(width, height)
        p
      end
    end
  end
end