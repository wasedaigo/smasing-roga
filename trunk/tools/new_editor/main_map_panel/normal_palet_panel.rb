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

    	def on_drag_motion(e)
       
        
        if e.button == 1
          tx, ty = self.calc_scrolled_position(0, 0)
          @ex = ((e.x - tx) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
          @ey = ((e.y - ty) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
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