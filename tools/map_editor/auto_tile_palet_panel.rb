require "scenes/map/config"
require "palet_panel"

module DRPGTool
  class AutoTilePaletPanel < PaletPanel
    attr_reader :texture
    attr_accessor :zoom
    
    def initialize(parent, id, size)
      super(parent, id, size)
      @chipset_no = 0
    end

    
    def render_chips(s)
      TestMapChipset.render_sample(s, 0, 0, 0)
      TestMapChipset.render_sample(s, 1, 0, 1)
      TestMapChipset.render_sample(s, 2, 0, 2)
      TestMapChipset.render_sample(s, 3, 0, 3)
      TestMapChipset.render_sample(s, 4, 0, 4)
      TestMapChipset.render_sample(s, 5, 0, 5)
      self.render_frame(s) if @active
    end
  end
end
