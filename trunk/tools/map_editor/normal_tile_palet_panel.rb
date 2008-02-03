require "scenes/map/config"
require "palet_panel"

module DRPGTool
  class NormalTilePaletPanel < PaletPanel
    attr_reader :texture
    attr_accessor :zoom
    
    def initialize(parent, id, size)
      super(parent, id, size)
      @chipset_no = 1
    end
 
  	def on_motion(e)
      if e.dragging && e.left_is_down
        tx, ty = self.calc_scrolled_position(0, 0)
        @ex = ((e.get_x - tx) / (Config::GRID_SIZE.to_f * @zoom)).floor
        @ey = ((e.get_y - ty) / (Config::GRID_SIZE.to_f * @zoom)).floor
      end
      
      self.refresh
  	end

    def render_chips(s)
      TestMapChipset2.render_sample(s, 0, 0)
      self.render_frame(s) if @active
    end
  end
end
