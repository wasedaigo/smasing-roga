require "scenes/map/map_chipset"
require "scenes/map/auto_palet_chip"

module SRoga
  class AutoMapChipset < MapChipset

    attr_reader :chip_size, :texture, :palet_chips

    def self.load(filename)
    
    end
    
    def initialize(filename, chip_size)
      super(filename, chip_size)
      raise(IndexError) if ((@texture.width % (3 * @chip_size)) != 0) || (@texture.height % (4 * @chip_size) != 0)

      @half = 0.5 * @chip_size
      @one = @chip_size
      @double = 2 * @chip_size
      @double_half = 2.5 * @chip_size
      @triple = 3 * @chip_size
      @triple_half = 3.5 * @chip_size

      @palet_chips = []
      (self.w_count * self.h_count).times do |i|
        @palet_chips << SRoga::AutoPaletChip.new(self, i, self.w_count, CollisionType::NONE)
      end
    end

    def width
      return self.w_count * @chip_size
    end

    def height
      return self.h_count * @chip_size
    end
    
    def w_count
      @texture.width / (3 * chip_size)
    end

    def h_count
      @texture.height / (4 * chip_size)
    end
    
    def sample_texture
      if @sample_texture.nil?
        @sample_texture = Texture.new(self.width, self.height)
        
        self.w_count.times do |i|
          self.h_count.times do |j|
            p i,j
            @sample_texture.render_texture(
              @texture, 
              i * @chip_size, 
              j * @chip_size, 
              :src_x => 3 * i * @chip_size + @one, 
              :src_y => 4 * j * @chip_size, :src_width => @one, 
              :src_height => @one
            )
          end
        end
      end
      
      return @sample_texture
    end
  end
end
