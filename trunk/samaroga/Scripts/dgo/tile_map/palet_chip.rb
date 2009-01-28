module DGO
  module TileMap
    class PaletChip
      attr_reader :chipset, :sx, :sy, :no
      attr_accessor :collision_type, :priority

      def initialize(chipset, no, width, collision_type, priority, readonly = false)
        @chipset = chipset
        @no = no
        @width = width
        @sx = no % width
        @sy = no / width
        @collision_type = collision_type
        @priority = priority
        @readonly = readonly
      end

      def readonly?
        return @readonly
      end
      
      def self.generate_empty_paletchip(readonly)
        return PaletChip.new(nil, 0, 1, 0, 1, readonly)
      end
      
      def render(s, x, y, mode, dx, dy, sub_no1, sub_no2, frame)
        s.render_texture(@chipset.texture, 
                         x * @chipset.grid_width - dx, 
                         y * @chipset.grid_height - dy, 
                         :src_x => @sx * @chipset.grid_width, 
                         :src_y => @sy * @chipset.grid_height,  
                         :src_width => @chipset.grid_width, 
                         :src_height=> @chipset.grid_height
                         )
      end   

      def ==(target)
        return false if target.nil? || target.chipset.nil? || self.chipset.nil?
        return self.chipset.name == target.chipset.name && self.chipset.type == target.chipset.type && self.no == target.no
      end
      
      def get_subs(tx, ty, map_data)
        return 0, 0
      end
    end
  end
end
