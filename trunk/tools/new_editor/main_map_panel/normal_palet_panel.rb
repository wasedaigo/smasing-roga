require "gadgets/frame"
require "scenes/map/config"
require "scenes/map/chip_data"

module Editor
  module Map
    class NormalPaletPanel < PaletPanel
      attr_reader :texture
      attr_accessor :zoom
      
      def initialize(h)
        super(h)
        @chipset_no = 0
      end
      
      def load_chipset
        @chipset = SRoga::MapChipset.new("ChipSet", 16)
        @scroll_box.set_client_size(@chipset.width * @zoom, @chipset.height * @zoom)
      end

    	def on_motion(e)
        if @left_pressed
          tx = ((e.x + self.scroll_x) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          ty = ((e.y + self.scroll_y) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          if tx >= 0 && ty >= 0 && tx < self.grid_x && ty < self.grid_y
            @ex = ((e.x + self.scroll_x) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
            @ey = ((e.y + self.scroll_y) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          end
        end
        
        self.render
    	end

      # def render_chips(s)
        # TestMapChipset2.render_sample(s, 0, 0)
        # self.render_frame(s) if @active
      # end
    end
  end
end