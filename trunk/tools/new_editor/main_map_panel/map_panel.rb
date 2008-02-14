require 'scenes/map/map'
require 'scenes/map/map_layer'
require 'scenes/map/map_chipset'
require 'scenes/map/auto_map_chipset'
require 'scenes/map/map_loader'
require 'scenes/map/config'

module Editor
  module Map
    class Mappanel  < Gtk::ScrolledWindow
      TestMapChipset = SRoga::AutoMapChipset.new("ChipSet2", 16)
      TestMapChipset2 = SRoga::MapChipset.new("ChipSet", 16)

      def initialize(palets)
        super()
        self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
        data = SRoga::MapLoader.loadMap
        @tile_w_count = data[:wCount]
        @tile_h_count = data[:hCount]
        @map_width = @tile_w_count * SRoga::Config::GRID_SIZE
        @map_height = @tile_h_count * SRoga::Config::GRID_SIZE
        @map = SRoga::Map.new(@tile_w_count, @tile_h_count, @tile_w_count, @tile_h_count, data[:collisionData], 0  => TestMapChipset, 1  => TestMapChipset2)
        @layers = [SRoga::MapLayer.new(@map, data[:bottomLayer]), SRoga::MapLayer.new(@map, data[:topLayer])]
        @texture = StarRuby::Texture.new(@map.width, @map.height)
        @zoom = 1
        @image = Gtk::Image.new
        @image.set_alignment(0, 0)
        @memory = nil
        @palets = palets
        @using_palet_no = 0
        @current_layer_no = 0
        
        self.set_panel
        self.render
      end
      
      def set_panel
        t = Gtk::EventBox.new
        t.add_events(Gdk::Event::POINTER_MOTION_MASK)
        t.add(@image)
        self.add_with_viewport(t)
        self.set_signals(t)
      end
      
      def set_signals(target)
        target.signal_connect("event") do |item, event|
          case(event.event_type)
            when(Gdk::Event::BUTTON_PRESS)
              case(event.button)
                when 1
                  self.on_left_down(event)
                when 3
                  self.on_right_down(event)
              end
            when(Gdk::Event::DRAG_MOTION)
              self.on_drag_motion(event)
          end
        end
      end

      # Property
      def current_layer
        return @layers[@current_layer_no]
      end
      
      def palet
        return @palets[@using_palet_no]
      end
    
      #Standard methods
      def update_panel
        @map.base_x = 0
        @map.base_y = 0
        @map.update(@map_width, @map_height, [@layers[0]])
        @texture.clear
        @layers.each{|layer|@map.render(@texture, layer)}

        tx = 0
        ty = 0
        tw = @map_width * @zoom
        th = @map_height * @zoom
        ttx = -tx / @zoom
        tty = -ty / @zoom

        @dst_texture = Texture.new(tw, th)
        @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom, :src_x => ttx, :src_y => tty, :src_width => [tw, @texture.width - ttx].min, :src_height => [th, @texture.height - tty].min)
      end

      def render
        update_panel
        @image.pixbuf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @dst_texture.width, @dst_texture.height, @dst_texture.width * 3)
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
          current_layer.render_new_part(sx - 1, sy - 1, sx - 1, sy - 1, 2 + self.palet.frame_w, 2 + self.palet.frame_h)
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
        p "LEFT_DOWN"
        tx = self.hadjustment.value
        ty = self.vadjustment.value
        sx = ((event.x - tx) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        sy = ((event.y - ty) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        @draw_sx = sx
        @draw_sy = sy
        self.put_tile(sx, sy)
      end
    
      def on_drag_motion(event)
        p "MOTION"
      end
      
      def on_right_down(event)
        p "RIGHT_DOWN"
        return true
        tx = self.hadjustment.value
        ty = self.vadjustment.value
        tx2 = ((e.get_x - tx1) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        ty2 = ((e.get_y - ty1) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        
        self.select(tx2, ty2)
        self.set_default_frame(e.get_x, e.get_y)
      end
    end
  end
end