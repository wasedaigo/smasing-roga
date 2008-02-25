require  "lib/table"
require  "scenes/map/collision_type"
require  "scenes/map/chip_data"

  module SRoga
  class MapChipset
    attr_accessor  :chip_size, :texture

    def initialize(filename, chip_size)
      @chip_size = chip_size
      @texture = $res.get_texture(filename)

      @collisions = Array.new(w_count * h_count)
      for i in (0..@collisions.length)
        @collisions[i] = 0
      end

      @collisions[0] = CollisionType::ALL
      @collisions[1] = CollisionType::NONE
      @collisions[2] = CollisionType::NONE
    end

    def collisionData(no)
      @collisions[no]
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

    def render(s, x, y, dx, dy, tx, ty, map_chipset_no, map_data)
      map_chip_no = ChipData.get_map_chip_no(map_data[tx, ty])
      #return if map_chip_no == 0
      s.render_texture(
        @texture, 
        x * @chip_size - dx, 
        y * @chip_size - dy, 
        :src_x => (map_chip_no % w_count ) * @chip_size, 
        :src_y => (map_chip_no / w_count ) * @chip_size,  
        :src_width=>@chip_size, :src_height=>@chip_size
      )
    end
    
    def render_sample(s, x, y, options = [])
      s.render_texture(@texture, x, y, options)
    end
  end
end