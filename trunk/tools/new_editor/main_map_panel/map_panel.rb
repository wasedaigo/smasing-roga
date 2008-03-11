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
    class MapPanel < Gtk::VBox
      
      ZOOMS = [0.5, 1, 2, 3, 4]
      def initialize(palets)
        super()
        
        data = SRoga::MapLoader.load_map([palets[0].chipset, palets[1].chipset])
        
        @tile_w_count = data[:w_count]
        @tile_h_count = data[:h_count]

        @zoom_index = 1
        @zoom = ZOOMS[@zoom_index]
     
        @map = SRoga::Map.new(@tile_w_count, @tile_h_count, 40, 40, SRoga::Config::GRID_SIZE, data[:collision_data])
        @layers = [SRoga::MapLayer.new(@map, data[:bottom_layer]), SRoga::MapLayer.new(@map, data[:top_layer])]

        @scroll_box = Editor::ScrollBox.new(@tile_w_count * self.grid_size, @tile_h_count * self.grid_size, self.grid_size) do |type|
          case type
            when "resize":
              @map.set_show_size(@scroll_box.w_grid_count, @scroll_box.h_grid_count, @layers)
              self.render
            when "render"
              self.render
          end
        end

        @memory = nil
        @palets = palets
        @current_palet = @palets[0]
        
        @current_layer_no = 0
        
        @left_pressed = false
        @right_pressed = false
        
        @psx = -1
        @psy = -1
        @pex = -1
        @pey = -1
        @pframe_width = -1
        @pframe_height = -1
        
        @frame = Frame.new
        
        @sx = -1
        @sy = -1
        @ex = -1
        @ey = -1
        @mx = -1
        @my = -1

        @invalidate_area = {:sx => -1, :sy => -1, :w_count => -1, :h_count => -1}
        
        # self.set_panel
        self.set_panel
        self.set_signals
        self.render
        
        # self.set_map_size(@tile_w_count, @tile_h_count)
        # self.render
      end
      
      # def queue_resize_no_redraw
        # super
        # @scroll_box.queue_resize_no_redraw
        # @scroll_box.content_image.queue_resize_no_redraw
      # end
      
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
      def current_layer_no=(value)
        @current_layer_no = value
        self.render
      end
      
      def current_layer
        return @layers[@current_layer_no]
      end
      
      def grid_size
        return @map.grid_size * @zoom
      end
    
      def scroll_x
        return @scroll_box.h_scrollbar.value.floor * self.grid_size
      end
      
      def scroll_y
        return @scroll_box.v_scrollbar.value.floor * self.grid_size  
      end
      
      def scroll_w_count
        return @scroll_box.h_scrollbar.value.floor
      end
      
      def scroll_h_count
        return @scroll_box.v_scrollbar.value.floor
      end

      def w_count
        (@scroll_box.width / self.grid_size).floor
      end
      
      def h_count
        (@scroll_box.height / self.grid_size).floor
      end
      
      def zoom=(value)
        @zoom = value
        @scroll_box.set_client_size(@tile_w_count * self.grid_size, @tile_h_count * self.grid_size)
        @scroll_box.grid_size = self.grid_size
        @scroll_box.refresh_scrollbars
        @scroll_box.on_resize
      end

      def zoom_in
        @zoom_index += 1 if @zoom_index < ZOOMS.length - 1
        self.zoom = ZOOMS[@zoom_index]
      end
      
      def zoom_out
        @zoom_index -= 1 if @zoom_index >0
        self.zoom = ZOOMS[@zoom_index]
      end
# methods

      def update_panel
        @map.base_x = self.scroll_x / @zoom
        @map.base_y = self.scroll_y  / @zoom

        if @texture.nil? || (@texture.width != @map.show_width || @texture.height != @map.show_height)
          @texture = StarRuby::Texture.new(@map.show_width, @map.show_height)
        end
        @texture.fill(Color.new(0, 0, 0, 255))
        
        @map.update(self.w_count, self.h_count, @layers)

        @map.render(@texture, @layers[0])
        
        if(@layers[1] == self.current_layer)
          @map.render(@texture, @layers[1])
        else
          @map.render(@texture, @layers[1], :alpha => 120)
        end
        @frame.render(@texture, self.grid_size / @zoom, [@sx, @ex].min - self.scroll_w_count, [@sy, @ey].min - self.scroll_h_count)

        tw = @invalidate_area[:w_count] < 0 ? @scroll_box.width : @invalidate_area[:w_count] * self.grid_size
        th = @invalidate_area[:h_count] < 0 ? @scroll_box.height : @invalidate_area[:h_count] * self.grid_size

        if(@dst_texture.nil? || (@dst_texture.width != tw || @dst_texture.height != th))
          @dst_texture = Texture.new(tw, th)
        end
        
        tx = @invalidate_area[:sx] < 0 ? 0 : [(@invalidate_area[:sx] - self.scroll_w_count) * @map.grid_size, 0].max
        ty = @invalidate_area[:sy] < 0 ? 0 : [(@invalidate_area[:sy] - self.scroll_h_count) * @map.grid_size, 0].max

         if(tx < @texture.width && ty < @texture.height)
          @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom, :src_x => tx, :src_y => ty, :src_width => [tw / @zoom, @texture.width - tx].min, :src_height => [th / @zoom, @texture.height - ty].min)
         end
      end

      def render
        self.update_panel
        area = @scroll_box.content_image
        return if area.window.nil?

        # dst_x = @sx * self.grid_size
        # dst_y = @sy * self.grid_size
        dst_x = @invalidate_area[:sx] < 0 ? 0 : (@invalidate_area[:sx] - self.scroll_w_count) * self.grid_size
        dst_y = @invalidate_area[:sy] < 0 ? 0 : (@invalidate_area[:sy] - self.scroll_h_count) * self.grid_size

        tw = @dst_texture.width
        th = @dst_texture.height

        #if((dst_x + buf > @scroll
        buf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, tw, th, tw * 3)
        gc = Gdk::GC.new(area.window) 
        area.window.draw_pixbuf(gc, buf, 0, 0, dst_x, dst_y, buf.width, buf.height, Gdk::RGB::DITHER_NONE, 0, 0)
 
        @psx = @sx
        @psy = @sy
        @pex = @ex
        @pey = @ey
        @pframe_width = @frame.width
        @pframe_height = @frame.height
        
        @invalidate_area = {:sx => -1, :sy => -1, :w_count => -1, :h_count => -1}
        
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
        if @current_palet.active?

          @current_palet.each_chip_info do |id, tx, ty|
            ttx = (tx - (sx - @draw_sx) % @current_palet.frame.width) % @current_palet.frame.width
            tty = (ty - (sy - @draw_sy) % @current_palet.frame.height) % @current_palet.frame.height
            if current_layer.map_data.exists?(sx + ttx, sy + tty)
              current_layer.map_data[sx + ttx, sy + tty].palet_chip = id
            end
          end
          
          current_layer.update_complementary_data(sx - 1 - self.scroll_w_count, sy - 1 - self.scroll_h_count, sx - 1, sy - 1, 2 + @current_palet.frame.width, 2 + @current_palet.frame.height)
          current_layer.render_new_part(sx - 1 - self.scroll_w_count, sy - 1 - self.scroll_h_count, sx - 1, sy - 1, 2 + @current_palet.frame.width, 2 + @current_palet.frame.height)
        else
          #p "-----------------"
          @memory.each_with_two_index do |id, tx, ty|
            ttx = (tx - (sx - @draw_sx) % @frame.width) % @frame.width
            tty = (ty - (sy - @draw_sy) % @frame.height) % @frame.height
            #p "chipNo #{id} ttx #{ttx}, tty #{tty} @frame.width #{@frame.width}"
            if current_layer.map_data.exists?(sx + ttx, sy + tty)
              current_layer.map_data[sx + ttx, sy + tty].palet_chip = id
            end
          end
          #p "-----------------"
          
          current_layer.update_complementary_data(sx - 1 - self.scroll_w_count, sy - 1 - self.scroll_h_count, sx - 1, sy - 1, 2 + @memory.width, 2 + @memory.height)
          current_layer.render_new_part(sx - 1 - self.scroll_w_count, sy - 1 - self.scroll_h_count, sx - 1, sy - 1, 2 + @memory.width, 2 + @memory.height)
        end
    	end
    
      def set_default_frame(x, y)
        @sx, @sy = self.get_abs_location(x, y)

        if @current_palet.active?
          @ex = @sx + @current_palet.frame.width - 1
          @ey = @sy + @current_palet.frame.height - 1
          @frame.set_size(@current_palet.frame.width, @current_palet.frame.height)          
        else
          @ex = @sx + @frame.width - 1
          @ey = @sy + @frame.height - 1
        end
      end
      
      def select(x, y)
        @sx = x
        @sy = y
        @ex = @sx
        @ey = @sy

        self.set_current_palet(current_layer.map_data[@sx, @sy].palet_chip.chipset)
        
        @palets.each{|palet|palet.active = false}
        @current_palet.active = true
        @current_palet.select_chip_by_no(current_layer.map_data[@sx, @sy].palet_chip.chip_no)
      end
 
      def set_current_palet(chipset)
        @palets.each_with_index do |obj, i|
          if obj.chipset == chipset
            @current_palet = obj
            break
          end
        end
      end
 
      def get_abs_location(x, y , b = true)
        sx = (([x, 0].max + self.scroll_x) / self.grid_size.to_f).floor
        sy = (([y, 0].max + self.scroll_y) / self.grid_size.to_f).floor
        
        if(b)
          sx = [sx, self.scroll_w_count + self.w_count - @frame.width].min
          sy = [sy, self.scroll_h_count + self.h_count - @frame.height].min
        end
        return sx, sy
      end
      
      def invalidate(auto, tx = 0, ty =0, tw = 0, th = 0)
        if(auto)
 
          p "ty #{ty} sy #{@sy} psy#{@psy}"
          if((@sx != @psx) || (@sy != @psy) || (@ex != @pex) || (@ey != @pey) || (@pframe_width != @frame.width) || (@pframe_height != @frame.height))
            @psx = @sx if(@psx < 0)
            @psy = @sy if(@psy < 0)
           
            # sx = [[@psx, self.scroll_w_count].max, [@sx, @ex].min + tx, self.scroll_w_count + self.w_count - 1].min
            # sy = [[@psy, self.scroll_h_count].max, [@sy, @ey].min + ty, self.scroll_h_count + self.h_count - 1].min
            # sw = [tw + @frame.width + (@sx - [@psx, 0].max).abs, self.scroll_w_count + self.w_count - sx].min
            # sh = [th + @frame.height + (@sy - @psy).abs, self.scroll_h_count + self.h_count - sy].min

            # if(sx < 0)
              # sw += sx
              # sx = 0
            # end
            # if(sy < 0)
              # sh += sy
              # sy = 0
            # end
          
            sx = tx + [@psx, @pex, @sx, @ex].min
            sy = ty + [@psy, @pey, @sy, @ey].min          
            ex = tw + [[@psx, @pex].min + @pframe_width, [@sx, @ex].min + @frame.width].max
            ey = th + [[@psy, @pey].min + @pframe_height, [@sy, @ey].min + @frame.height].max

            sw = ex - sx
            sh = ey - sy
            
            p "@sx#{@sx} sx:#{sx} sy:#{sy} sw#{sw} sh:#{sh}, a#{self.scroll_h_count + self.h_count - sy}"
            if(sx >= 0 && sy >= 0 && sw >= 1 && sh >= 1)
              @invalidate_area = {:sx => sx, :sy => sy, :w_count => sw, :h_count => sh}
              self.render
            end
            
          end
        else
          @invalidate_area = {:sx => -1, :sy => -1, :w_count => -1, :h_count => -1}
          self.render
        end
      end
      
      #Events
      def on_left_down(event)
        @palets.each_with_index do |obj, i|
          if obj.active
            @current_palet = obj
            break
          end
        end

        @psx = -1
        @psy = -1
        @sx, @sy = get_abs_location(event.x, event.y)
        @ex, @ey = @sx, @sy
        
        @left_pressed = true

        @draw_sx = @sx
        @draw_sy = @sy
        
        self.put_tile(@sx, @sy)
        self.invalidate(true, -1, -1, 2, 2)
      end

      def on_left_up(event)
        @left_pressed = false
      end
      
      def on_motion(event)
        @mode = :put
        
        tx = 0
        ty = 0
        tw = 0
        th = 0
        if @left_pressed
          @sx, @sy = get_abs_location(event.x, event.y)
          self.put_tile(@sx, @sy)
          tx = -1
          ty = -1
          tw = 2
          th = 2
        end
        
        if @right_pressed
          @mode = :select

          ttx, tty = get_abs_location(event.x, event.y, false)
          if self.current_layer.map_data.exists?(ttx, tty)
            @ex, @ey = ttx, tty
          end

          @ex = [@ex, self.scroll_w_count + self.w_count - 1].min
          @ey = [@ey, self.scroll_h_count + self.h_count - 1].min

          @frame.set_size((@ex - @sx).abs + 1, (@ey - @sy).abs + 1)
        end

        if @mode == :put
          self.set_default_frame(event.x, event.y)
        end

        self.invalidate(true, tx, ty, tw, th)
      end
        
      def on_right_down(e)
        tx, ty = get_abs_location(e.x, e.y)
        unless self.current_layer.map_data.exists?(tx, ty)
          return
        end
        
        self.select(tx, ty)
        self.set_default_frame(e.x , e.y)
        @right_pressed = true
        
        @frame.set_size(1, 1)
        self.invalidate(false)
      end

      def on_right_up(e)
        @right_pressed = false
        return if @mode != :select
        
        @frame.set_size((@ex - @sx).abs + 1, (@ey - @sy).abs + 1)
        
        @mode = :put
        @memory = nil
        
        unless @frame.width == 1 && @frame.height == 1
          arr = []
          (0 .. (@sy - @ey).abs).each do |ty|
            (0 .. (@sx - @ex).abs).each do |tx|
              arr << current_layer.map_data[[@sx, @ex].min + tx, [@sy, @ey].min + ty].palet_chip
            end
          end

          @memory = DLib::Table.new((@sx - @ex).abs + 1, arr)
          @palets.each{|palet|palet.active = false}
        end

        self.invalidate(false)
      end

      
      def on_resize(width, height)
        @scroll_box.set_size_request(width, height)
        p
      end
    end
  end
end