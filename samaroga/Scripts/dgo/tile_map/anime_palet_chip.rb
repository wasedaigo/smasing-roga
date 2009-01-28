require "dgo/tile_map/palet_chip"
module DGO
  module TileMap
    class AnimePaletChip < PaletChip

      def initialize(chipset, chip_no, width, collision_data, priority)
        super(chipset, chip_no, width, collision_data, priority)
      end
      
      def render(s, x, y, mode, dx, dy, sub_no1, sub_no2, frame)
        s.render_texture(@chipset.textures[frame], 
                         x * @chipset.grid_width - dx, 
                         y * @chipset.grid_height - dy, 
                         :src_x => @sx * @chipset.grid_width, 
                         :src_y => @sy * @chipset.grid_height,  
                         :src_width => @chipset.grid_width, 
                         :src_height=> @chipset.grid_height,
                         :blend_type => mode
                         )
      end 
    end
  end
end
