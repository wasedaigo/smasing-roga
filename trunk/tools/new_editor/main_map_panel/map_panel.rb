require 'scenes/map/map'
require 'scenes/map/map_layer'
require 'scenes/map/map_chipset'
require 'scenes/map/auto_map_chipset'
require 'scenes/map/map_loader'
require 'scenes/map/config'
require 'gadgets/scroll_box'

module Editor
  module Map
    class Mappanel  < Gtk::VBox

      def initialize(palets)
        super()

        # self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
        data = SRoga::MapLoader.loadMap
        @tile_w_count = data[:wCount]
        @tile_h_count = data[:hCount]
       
        @scroll_box = Editor::ScrollBox.new(@tile_w_count * SRoga::Config::GRID_SIZE, @tile_h_count * SRoga::Config::GRID_SIZE, 640, 640)
        
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
        
        @zoom = 1

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

        $window.signal_connect("configure-event") do |item, event|
          self.on_resize(event)
        end
        
        @scroll_box.h_scrollbar.adjustment.signal_connect("value-changed") do |item, event|
          self.render
        end

        @scroll_box.v_scrollbar.adjustment.signal_connect("value-changed") do |item, event|
          self.render
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
      
      def palet
        return @palets[@using_palet_no]
      end
    
      def h_scroll_tiles
        return (@scroll_box.h_scrollbar.value / (SRoga::Config::GRID_SIZE * @zoom)).floor
      end
      
      def v_scroll_tiles
        return (@scroll_box.v_scrollbar.value / (SRoga::Config::GRID_SIZE * @zoom)).floor
      end
      
# methods
      def update_panel
        @map.base_x = @scroll_box.h_scrollbar.value
        @map.base_y = @scroll_box.v_scrollbar.value
        @map.update(@scroll_box.width, @scroll_box.height, [@layers[0]])

        @texture.clear
        @layers.each{|layer|@map.render(@texture, layer)}

        tw = @scroll_box.width * @zoom
        th = @scroll_box.height * @zoom

        @dst_texture = Texture.new(tw, th)
        @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom, :src_width => [tw, @texture.width].min, :src_height => [th, @texture.height].min)
      end

      def render
        update_panel
        @scroll_box.content_image.pixbuf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @dst_texture.width, @dst_texture.height, @dst_texture.width * 3)

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
        @image_box.set_size_request(w_count * SRoga::Config::GRID_SIZE * @zoom, h_count * SRoga::Config::GRID_SIZE * @zoom)
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
          
          current_layer.render_new_part(sx - 1, sy - 1, sx - 1, sy - 1, 2 + @memory.width, 2 + @memory.height)
        end
        
        self.render
    	end
    
      #Events
      def on_left_down(event)
        sx = ((event.x + @scroll_box.h_scrollbar.value) / (SRoga::Config::GRID_SIZE * @zoom).to_f).floor
        sy = ((event.y + @scroll_box.v_scrollbar.value) / (SRoga::Config::GRID_SIZE * @zoom).to_f).floor
        
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
        if @left_pressed
          on_left_down(event)
        end
      end
      
      def on_right_down(event)
      end
      
      def on_right_up(event)
      end
      
      def on_resize(event)
        p event.width
        #@scroll_box.content_image.set_size_request(self.allocation.width - 32, self.allocation.height - 32)
        #self.render
      end
    end
  end
end