require "gadgets/frame"
require "scenes/map/config"
require "scenes/map/chip_data"

PALET_ROW_COUNT = 8
module Editor
  module Map
    class PaletPanel < Gtk::ScrolledWindow
      include Frame
      attr_reader :chip_id, :chipset
      attr_accessor :zoom
      
      def initialize(h)
        super()
        self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

        @image = Gtk::Image.new
        @image.set_alignment(0, 0)

        self.set_height_request(h)
        
        @sx = 0
        @sy = 0
        @ex = 0
        @ey = 0
        @zoom = 2
        @frame_zoom = 2

        @chip_id = 0
        @chipset_no = 0
        @active = true

        @frame_w = 0
        @frame_h = 0
        
        self.set_panel
        self.render
      end
      
      
      def set_signals
        @image_box.signal_connect("motion-notify-event") do |item, event|
          self.on_motion(event)
        end
        
        @image_box.signal_connect("button-press-event") do |item, event|
          case(event.button)
            when 1
              self.on_left_down(event)
            when 3
              self.on_right_down(event)
          end
        end

        @image_box.signal_connect("button-release-event") do |item, event|
          case(event.button)
            when 1
              self.on_left_up(event)
            when 3
              self.on_right_up(event)
          end
        end
      end
        
      def set_panel
        @image_box = Gtk::EventBox.new
        @image_box.add_events(Gdk::Event::POINTER_MOTION_MASK)
        @image_box.add(@image)
        self.add_with_viewport(@image_box)
        set_background_image("Data/Icon/tex.png", @image_box)

        self.set_signals
      end

      #Property
      def active=(value)
        @active = value
        self.render
      end
      
      def active?
        return @active
      end
      
      #Standard Method
      def select(x, y)
        return if x >= @chipset.w_count || y >= @chipset.h_count
      
        @sx = x
        @sy = y
        @ex = @sx
        @ey = @sy
        
        self.render
      end
      
      def select_chip_by_id(id)
        tx1 = (id % PALET_ROW_COUNT) * SRoga::Config::GRID_SIZE * 2
        ty1 = (id / PALET_ROW_COUNT) * SRoga::Config::GRID_SIZE * 2

        tx2 = (tx1 / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        ty2 = (ty1 / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        self.select(tx2, ty2)
      end
    
      def render
        return if @chipset.nil?
        @dst_texture = Texture.new(@chipset.width * @zoom, @chipset.height * @zoom)
        @chipset.render_sample(@dst_texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom)
        self.render_frame(@dst_texture) if @active
        @image.pixbuf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @dst_texture.width, @dst_texture.height, @dst_texture.width * 3)
      end
      
      # Events
      def on_left_down(e)
        tx1 = self.hadjustment.value
        ty1 = self.vadjustment.value
        tx2 = (e.x / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        ty2 = (e.y / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
        self.select(tx2, ty2)
        @left_pressed = true
        self.active = true
      end
      
      def on_left_up(e)
        @left_pressed = false
      end

      def on_right_down(e)
        @right_pressed = true
      end
      
      def on_right_up(e)
        @right_pressed = false
      end
      
      #Iterator
      def each_chip_info
        (0 .. (@sx - @ex).abs).each do |x|
          (0 .. (@sy - @ey).abs).each do |y|
            yield SRoga::ChipData.generate(@chipset_no, ([@sy, @ey].min + y) * PALET_ROW_COUNT + ([@sx, @ex].min + x)), x, y
          end
        end
      end

    end
  end
end