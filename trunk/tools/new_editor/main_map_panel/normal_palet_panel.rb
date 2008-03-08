require "gadgets/frame"
require "scenes/map/config"

module Editor
  module Map
    class NormalPaletPanel < PaletPanel
      attr_reader :texture
      attr_accessor :zoom
      
      def initialize(palet_notebook, h)
        super(palet_notebook, h)
        @chipset_no = 0
      end
      
      def load_chipset
        @chipset = SRoga::MapLoader.load_normal_chipset
        @scroll_box.set_client_size(@chipset.width * @zoom, @chipset.height * @zoom)
      end

      # def render_chips(s)
        # TestMapChipset2.render_sample(s, 0, 0)
        # self.render_frame(s) if @active
      # end
    end
  end
end