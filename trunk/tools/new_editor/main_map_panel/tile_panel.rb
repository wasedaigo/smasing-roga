require "gadgets/frame"
require "scenes/map/config"
require "scenes/map/chip_data"

PALET_ROW_COUNT = 6
module Editor
  module Map
    class TilePanel < Gtk::ScrolledWindow
      include Frame
      attr_reader :chip_id
      attr_accessor :zoom
      
      def initialize(h)
        super()
        self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
        
        @texture = StarRuby::Texture.load("Data/ChipSet/Normal/test.png")
        @image = Gtk::Image.new
        @image.set_alignment(0, 0)

        
        self.add_with_viewport(@image)
        self.set_height_request(h)
        
        self.signal_connect("event") do |item, event|
          p event.event_type
        end
        @sx = 0
        @sy = 0
        @ex = 0
        @ey = 0
        @zoom = 2
        @frame_zoom = 1

        @chip_id = 0
        @chipset_no = 0
        @active = false

        @frame_w = 0
        @frame_h = 0
        
        self.update
      end
      
      #Property
      def active=(value)
        @active = value
        self.refresh
      end
      
      def active?
        return @active
      end
      
      #Standard Method
      def select(x, y)
        @sx = x
        @sy = y
        @ex = @sx
        @ey = @sy
        
        self.refresh
      end
      
      def select_chip_by_id(id)
        tx1 = (id % PALET_ROW_COUNT) * Config::GRID_SIZE * 2
        ty1 = (id / PALET_ROW_COUNT) * Config::GRID_SIZE * 2

        tx2 = (tx1 / (Config::GRID_SIZE.to_f * @zoom)).floor
        ty2 = (ty1 / (Config::GRID_SIZE.to_f * @zoom)).floor
        self.select(tx2, ty2)
      end
    
      def update
        @dst_texture = Texture.new(@texture.width * @zoom , @texture.height * @zoom)
        @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom)
        @image.pixbuf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @dst_texture.width, @dst_texture.height, @dst_texture.width * 3)
      end
      
      # Events
      def on_paint(dc)
        do_prepare_dc(dc)
        dc.draw_texture(@dst_texture, 0, 0)
      end
      
      def on_left_down(e)
        tx1, ty1 = self.calc_scrolled_position(0, 0)
        tx2 = ((e.get_x - tx1) / (Config::GRID_SIZE.to_f * @zoom)).floor
        ty2 = ((e.get_y - ty1) / (Config::GRID_SIZE.to_f * @zoom)).floor
        self.select(tx2, ty2)
      end
      

      #Iterator
      def each_chip_info
        (0 .. (@sx - @ex).abs).each do |x|
          (0 .. (@sy - @ey).abs).each do |y|
            yield ChipData.generate(@chipset_no, ([@sy, @ey].min + y) * PALET_ROW_COUNT + ([@sx, @ex].min + x)), x, y
          end
        end
      end
    
    end
  end
end