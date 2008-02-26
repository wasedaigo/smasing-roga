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
        @chipset_no = 1
      end
      
      def load_chipset
        @chipset = SRoga::MapChipset.new("ChipSet", 16)
      end
      
    	def on_motion(e)
        if @left_pressed
          tx = self.hadjustment.value
          ty = self.vadjustment.value
          @ex = ((e.x) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          @ey = ((e.y) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
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