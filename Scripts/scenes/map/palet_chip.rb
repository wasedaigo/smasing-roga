module SRoga
  class PaletChip

    attr_reader :chipset, :sx, :sy, :collision_data, :chip_no
    def initialize(chipset, chip_no, width, collision_data)
      @chipset = chipset
      @chip_no = chip_no
      @width = width
      @sx = chip_no % width
      @sy = chip_no / width
      @collision_data = collision_data
    end

    def render(s, x, y, dx, dy, sub_no1, sub_no2)
      s.render_texture(
        @chipset.texture, 
        x * @chipset.chip_size - dx, 
        y * @chipset.chip_size - dy, 
        :src_x => @sx * @chipset.chip_size, 
        :src_y => @sy * @chipset.chip_size,  
        :src_width => @chipset.chip_size, :src_height=> @chipset.chip_size
      )
    end   

    def ==(target)
      return false if target.nil?
      return self.chipset == target.chipset && self.chip_no == target.chip_no
    end
    
    def get_subs(tx, ty, map_data)
      return 0, 0
    end
    
    def immutable_palet_chip
       @chipset
    end
  end
end
