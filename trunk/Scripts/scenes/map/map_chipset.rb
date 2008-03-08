require "scenes/map/collision_type"
require "scenes/map/palet_chip"

  module SRoga
  class MapChipset
    attr_reader  :chip_size, :texture, :palet_chips

    def self.load(filename)

    end
    
    def initialize(filename, chip_size)

      @chip_size = chip_size
      @texture = $res.get_texture(filename)
      
      @palet_chips = []
      (self.w_count * self.h_count).times do |i|
        @palet_chips << SRoga::PaletChip.new(self, i, self.w_count, CollisionType::NONE)
      end
    end

    # property
    def collisionData(no)
      @palet_chips[no].collision_data
    end

    def width
      @texture.width
    end

    def height
      @texture.height
    end

    def w_count
      width / @chip_size
    end

    def h_count
      height / @chip_size
    end
        
    def sample_texture
      return @texture
    end
    
    #methods
    def render(s, x, y, dx, dy, tx, ty, map_chipset_no, map_data)
      map_data[tx, ty].render(x, y, dx, dy)
    end

    def render_sample(s, x, y, options = [])
      s.render_texture(self.sample_texture, x, y, options)
    end
  end
end
