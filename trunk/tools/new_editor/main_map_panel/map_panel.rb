require 'scenes/map/map'
require 'scenes/map/map_layer'
require 'scenes/map/map_chipset'
require 'scenes/map/auto_map_chipset'
require 'scenes/map/map_loader'
require 'scenes/map/config'
require 'gadgets/scroll_box'
require 'gadgets/frame'
require 'cairo'

module Editor
  module Map
    class Mappanel  < Gtk::VBox
      include Frame
      
      def initialize(palets)
        super()
        
        # self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
        data = SRoga::MapLoader.loadMap
        @tile_w_count = data[:wCount]
        @tile_h_count = data[:hCount]

        @zoom = 1
        @scroll_box = Editor::ScrollBox.new(@tile_w_count * self.grid_size, @tile_h_count * self.grid_size, self.grid_size) do |type|
          case type
            when "resize":
              @map.set_show_size(@scroll_box.w_grid_count, @scroll_box.h_grid_count, @layers)
              self.render
            when "render"
              self.render
          end
        end

        chipsets = {}
        palets.each_with_index do |palet, i|
          chipsets[i] = palet.chipset
        end

        @memory = nil
        @palets = palets
        @using_palet_no = 0
        @current_layer_no = 0
        
        @left_pressed = false
        @right_pressed = false
        @p_sx = -1
        @p_sy = -1
        
        @sx = 0
        @sy = 0
        @ex = 0
        @ey = 0
        
        @frame_zoom = 1
        
        @map = SRoga::Map.new(@tile_w_count, @tile_h_count, 40, 40, data[:collisionData], chipsets)
        @layers = [SRoga::MapLayer.new(@map, data[:bottomLayer]), SRoga::MapLayer.new(@map, data[:topLayer])]
        @texture = StarRuby::Texture.new(@map.width, @map.height)
        
        
        # self.set_panel
        self.set_panel
        self.set_signals
        self.render
        
        # self.set_map_size(@tile_w_count, @tile_h_count)
        # self.render
      end
      
      def queue_resize_no_redraw
        super
        @scroll_box.queue_resize_no_redraw
        @scroll_box.content_image.queue_resize_no_redraw
      end
      
      def set_panel
        self.add(@scroll_box)
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
      end

      # Property
      def client_size
        self.width
        self.height
        return w, h
      end
      
      def current_layer
        return @layers[@current_layer_no]
      end
      
      def grid_size
        return (SRoga::Config::GRID_SIZE * @zoom)
      end
      
      def palet
        return @palets[@using_palet_no]
      end
    
      def scroll_x
        return @scroll_box.h_scrollbar.value.floor * self.grid_size
      end
      
      def scroll_y
        return @scroll_box.v_scrollbar.value.floor * self.grid_size  
      end
      
      def h_scroll_tiles
        return @scroll_box.h_scrollbar.value.floor
      end
      
      def v_scroll_tiles
        return @scroll_box.v_scrollbar.value.floor
      end
      
# methods
      def update_panel
        @map.base_x = self.scroll_x / @zoom
        @map.base_y = self.scroll_y / @zoom
        @map.update(@scroll_box.width / @zoom, @scroll_box.height / @zoom, [@layers[0]])

        @texture.clear
        @layers.each{|layer|@map.render(@texture, layer)}

        #tw = [@scroll_box.content_width, @texture.width * @zoom].min
        #th = [@scroll_box.content_height, @texture.height * @zoom].min
        
        tw = @scroll_box.width
        th = @scroll_box.height
        
        self.render_frame(@texture, self.scroll_x, self.scroll_y)

        @dst_texture = Texture.new(tw, th)
        
        @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom, :src_width => [tw / @zoom, @texture.width].min, :src_height => [th / @zoom, @texture.height].min)
      end

      def render
        self.update_panel
        return if @scroll_box.content_image.window.nil?

        area = @scroll_box.content_image
        buf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @dst_texture.width, @dst_texture.height, @dst_texture.width * 3)
        area.window.draw_pixbuf(area.style.fg_gc(area.state), buf, 0, 0, 0, 0, @dst_texture.width, @dst_texture.height, Gdk::RGB::DITHER_NONE, 0, 0)
                
        #@scroll_box.content_image.window.cairo_create
        #@scroll_box.content_image.pixbuf = 

        #@image.set_padding(self.hadjustment.value, self.vadjustment.value)
        # if false
          # tx = self.hadjustment.value
          # ty = self.vadjustment.value
          # ttx = tx / @zoom
          # tty = ty / @zoom
          
          # pixbuf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, 32, 32, 32 * 3)
          # pixbuf.copy_area(ttx, , @dst_texture.width, @dst_texture.height, @image.pixbuf, 0, 0)
          # @image.queue_draw
        # end
      end
      
      def set_map_size(w_count, h_count)
        @map.set_size(w_count, h_count, @layers)
        @image_box.set_size_request(w_count * self.grid_size, h_count * self.grid_size)
      end
      
    	def put_tile(sx, sy)
        if self.palet.active?

          self.palet.each_chip_info do |id, tx, ty|
            ttx = (tx - (sx - @draw_sx) % self.palet.frame_w) % self.palet.frame_w
            tty = (ty - (sy - @draw_sy) % self.palet.frame_h) % self.palet.frame_h
            if current_layer.map_data.exists?(sx + ttx, sy + tty)
              current_layer.map_data[sx + ttx, sy + tty] = id
            end
          end
          
          current_layer.render_new_part(sx - 1 - self.h_scroll_tiles, sy - 1 - self.v_scroll_tiles, sx - 1, sy - 1, 2 + self.palet.frame_w, 2 + self.palet.frame_h)
        else
          @memory.each_with_two_index do |id, tx, ty|
            ttx = (tx - (sx - @draw_sx) % self.frame_w) % self.frame_w
            tty = (ty - (sy - @draw_sy) % self.frame_h) % self.frame_h
            
            if current_layer.map_data.exists?(sx + ttx, sy + tty)
              current_layer.map_data[sx + ttx, sy + tty] = id
            end
          end
          
          current_layer.render_new_part(sx - 1 - self.h_scroll_tiles, sy - 1 - self.v_scroll_tiles, sx - 1, sy - 1, 2 + @memory.width, 2 + @memory.height)
        end
        
        self.render
    	end
    
      def set_default_frame(x, y)
        @sx, @sy = self.get_abs_location(x, y)
        
        if self.palet.active?
          @ex = @sx + self.palet.frame_w - 1
          @ey = @sy + self.palet.frame_h - 1
        else
          @ex = @sx + @frame_w - 1
          @ey = @sy + @frame_h - 1
        end
      end
      
      def select(x, y)
        @sx = x
        @sy = y
        @ex = @sx
        @ey = @sy
        
        @using_palet_no = SRoga::ChipData.get_map_chipset_no(current_layer.map_data[@sx, @sy])
        @palets.each{|palet|palet.active = false}
        self.palet.active = true
        self.palet.select_chip_by_id(SRoga::ChipData.get_map_chip_no(current_layer.map_data[@sx, @sy]))
      end
 
      def get_abs_location(x, y)
        sx = ((x + self.scroll_x) / self.grid_size.to_f).floor
        sy = ((y + self.scroll_y) / self.grid_size.to_f).floor
        return sx, sy
      end
      
      #Events
      def on_left_down(event)
        sx, sy = get_abs_location(event.x, event.y)
        
        @left_pressed = true
        if @p_sx == sx && @p_sy == sy
          return
        end
        
        @p_sx = sx
        @p_sy = sy
        @draw_sx = sx
        @draw_sy = sy
        self.put_tile(sx, sy)
      end

      def on_left_up(event)
        @left_pressed = false
      end
      
      def on_motion(event)
      @mode = :put
      
      if @left_pressed
        sx, sy = get_abs_location(event.x, event.y)
        self.put_tile(sx, sy)
      end
      if @right_pressed
        @mode = :select
        
        tx, ty = get_abs_location(event.x, event.y)
        if self.current_layer.map_data.exists?(tx, ty)
          @ex, @ey = tx, ty
        end
      end

      if @mode == :put
        self.set_default_frame(event.x, event.y)
      end

      self.render
      end
        
      def on_right_down(e)
        tx, ty = get_abs_location(e.x, e.y)
        unless self.current_layer.map_data.exists?(tx, ty)
          return
        end
        self.select(tx, ty)
        self.set_default_frame(e.x , e.y)
        @right_pressed = true
      end

      def on_right_up(e)
        @mode = :put
        @memory = nil
        unless self.frame_w == 1 && self.frame_h == 1
          arr = []
          (0 .. (@sy - @ey).abs).each do |ty|
            (0 .. (@sx - @ex).abs).each do |tx|
              arr << current_layer.map_data[[@sx, @ex].min + tx, [@sy, @ey].min + ty]
            end
          end

          @memory = Table.new((@sx - @ex).abs + 1, arr)
          @palets.each{|palet|palet.active = false}
        end
        @right_pressed = false
      end

      
      def on_resize(width, height)
        @scroll_box.set_size_request(width, height)
        p ""
      end
    
    end
  end
end