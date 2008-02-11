require  "scenes/map/map_chipset"
require  "scenes/map/chip_position_type"
require  "scenes/map/chip_data"

module SRoga
  class AutoMapChipset < MapChipset

    attr_accessor  :chip_size, :texture

    def initialize(filename, chip_size)
      super(filename, chip_size)
      raise(IndexError) if ((width % (3 * chip_size)) != 0) || (height != (4 * chip_size))

      @half = 0.5 * @chip_size
      @one = @chip_size
      @double = 2 * @chip_size
      @double_half = 2.5 * @chip_size
      @triple = 3 * @chip_size
      @triple_half = 3.5 * @chip_size

      @collisions[0] = CollisionType::ALL
      @collisions[1] = CollisionType::NONE
    end

    def w_count
      width / (3 * chip_size)
    end

    def h_count
      height / (4 * chip_size)
    end

    #
    # Render
    #
    def renderTopRight(s, t, tx, ty, no)
      return if (no & ChipPositionType::TOP_RIGHT) == ChipPositionType::TOP_RIGHT
      s.render_texture(@texture, tx + 0.75 * @chip_size, ty, :src_x => t + 2.75 * @chip_size, :src_y => 0,  :src_width=>@chip_size / 4, :src_height=>@chip_size / 4)
    end

    def renderTopLeft(s, t, tx, ty, no)
      return if (no & ChipPositionType::TOP_LEFT) == ChipPositionType::TOP_LEFT
      s.render_texture(@texture, tx, ty, :src_x => t + 2 * @chip_size, :src_y => 0,  :src_width=>@chip_size / 4, :src_height=>@chip_size / 4)
    end

    def renderRightBottom(s, t, tx, ty, no)
      return if (no & ChipPositionType::RIGHT_BOTTOM) == ChipPositionType::RIGHT_BOTTOM
      s.render_texture(@texture, tx + 0.75 * @chip_size, ty + 0.75 * @chip_size, :src_x => t + 2.75 * @chip_size, :src_y => 0.75 * @chip_size,  :src_width=>@chip_size / 4, :src_height=>@chip_size / 4)
    end

    def renderBottomLeft(s, t, tx, ty, no)
      return if (no & ChipPositionType::BOTTOM_LEFT) == ChipPositionType::BOTTOM_LEFT
      s.render_texture(@texture, tx, ty + 0.75 * @chip_size, :src_x => t + 2 * @chip_size, :src_y => 0.75 * @chip_size,  :src_width=>@chip_size / 4, :src_height=>@chip_size / 4)
    end

    # render chips by auto complete method
    def render_chip(s, x, y, no, subNo1, subNo2)
      t = (3 * no) * @chip_size
      tx = x
      ty = y

      case subNo1

      when ChipPositionType::TOP
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y => @triple,  :src_width => @half, :src_height => @one)
        s.render_texture(@texture, tx + @half, ty, :src_x => t + @double_half, :src_y => @triple,  :src_width => @half, :src_height => @one)

      when ChipPositionType::RIGHT
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y => @one,  :src_width => @chip_size, :src_height => @half)
        s.render_texture(@texture, tx, ty + @half, :src_x => t, :src_y => @triple_half,  :src_width => @one, :src_height => @half)

      when ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y =>@one,  :src_width => @half, :src_height=>@chip_size)
        s.render_texture(@texture, tx + @half, ty, :src_x => t + @double_half, :src_y =>@chip_size,  :src_width => @half, :src_height=>@chip_size)

      when ChipPositionType::LEFT
        s.render_texture(@texture, tx, ty, :src_x => t + @double, :src_y => @one,  :src_width => @one, :src_height => @half)
        s.render_texture(@texture, tx, ty + @half, :src_x => t + @double, :src_y => @triple_half,  :src_width => @one, :src_height => @half)

      when ChipPositionType::TOP | ChipPositionType::RIGHT
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y => @triple,  :src_width => @one, :src_height => @one)
        renderTopRight(s, t, tx, ty, subNo2)

      when ChipPositionType::TOP | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y => @double,  :src_width => @half, :src_height=>@chip_size)
        s.render_texture(@texture, tx + @half, ty, :src_x => t + @double_half, :src_y => @double,  :src_width => @half, :src_height => @chip_size)

      when ChipPositionType::TOP | ChipPositionType::LEFT
        s.render_texture(@texture, tx, ty, :src_x => t + @double, :src_y => @triple,  :src_width => @one, :src_height => @one)
        renderTopLeft(s, t, tx, ty, subNo2)

      when ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t , :src_y => @one,  :src_width => @one, :src_height => @one)
        renderRightBottom(s, t, tx, ty, subNo2)

      when ChipPositionType::RIGHT | ChipPositionType::LEFT
        s.render_texture(@texture, tx, ty, :src_x => t + @one, :src_y => @one,  :src_width => @one, :src_height => @half)
        s.render_texture(@texture, tx, ty + @half, :src_x => t + @one, :src_y => @triple_half,  :src_width => @one, :src_height => @half)

      when ChipPositionType::BOTTOM | ChipPositionType::LEFT
        s.render_texture(@texture, tx, ty, :src_x => t + @double, :src_y => @one, :src_width => @one, :src_height => @one)
        renderBottomLeft(s, t, tx, ty, subNo2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::LEFT
        s.render_texture(@texture, tx, ty, :src_x => t + @one, :src_y => @triple, :src_width => @one, :src_height => @one)
        renderTopRight(s, t, tx, ty, subNo2)
        renderTopLeft(s, t, tx, ty, subNo2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y => @double, :src_width => @one, :src_height => @one)
        renderTopRight(s, t, tx, ty, subNo2)
        renderRightBottom(s, t, tx, ty, subNo2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y => @double, :src_width => @one, :src_height => @one)
        renderTopRight(s, t, tx, ty, subNo2)
        renderRightBottom(s, t, tx, ty, subNo2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t, :src_y => @double, :src_width => @one, :src_height => @one)
        renderTopRight(s, t, tx, ty, subNo2)
        renderRightBottom(s, t, tx, ty, subNo2)

      when ChipPositionType::TOP | ChipPositionType::LEFT | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t + @double, :src_y => @double, :src_width => @one, :src_height => @one)
        renderTopLeft(s, t, tx, ty, subNo2)
        renderBottomLeft(s, t, tx, ty, subNo2)

      when ChipPositionType::RIGHT | ChipPositionType::LEFT | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t + @one, :src_y => @one, :src_width => @one, :src_height => @one)
        renderRightBottom(s, t, tx, ty, subNo2)
        renderBottomLeft(s, t, tx, ty, subNo2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::LEFT | ChipPositionType::BOTTOM
        s.render_texture(@texture, tx, ty, :src_x => t + @one, :src_y => @double, :src_width => @one, :src_height => @one)
        renderTopLeft(s, t, tx, ty, subNo2)
        renderTopRight(s, t, tx, ty, subNo2)
        renderRightBottom(s, t, tx, ty, subNo2)
        renderBottomLeft(s, t, tx, ty, subNo2)

      when ChipPositionType::NONE
        s.render_texture(@texture, tx, ty, :src_x => t + @one, :src_y => 0, :src_width => @one, :src_height => @one)
      end
    end

    # check the chip at optional position
    def same_chip?(x, y, no, map_chipset_no, map_data)
      if map_data.exists?(x, y)
        return ChipData.equal?(map_data[x, y], map_chipset_no, no)
      else
        return false
      end
    end

    def render(s, x, y, dx, dy, tx, ty, map_chipset_no, map_data)
      return unless map_data.exists?(x, y)
      no = ChipData.get_map_chip_no(map_data[tx, ty])

      leftX = tx - 1
      middleX = tx
      rightX = tx + 1

      topY = ty - 1
      middleY = ty
      bottomY = ty + 1

      # check chips around this chip
      # subNo1 and subNo2 should be calculated beforehand
      subNo1 = 0
      subNo1 |= ChipPositionType::TOP if same_chip?(middleX, topY, no, map_chipset_no, map_data)
      subNo1 |= ChipPositionType::RIGHT if same_chip?(rightX, middleY, no, map_chipset_no, map_data)
      subNo1 |= ChipPositionType::BOTTOM if same_chip?(middleX, bottomY, no, map_chipset_no, map_data)
      subNo1 |= ChipPositionType::LEFT if same_chip?(leftX, middleY, no, map_chipset_no, map_data)

      subNo2 = 0
      subNo2 |= ChipPositionType::TOP_LEFT if same_chip?(leftX, topY, no, map_chipset_no, map_data)
      subNo2 |= ChipPositionType::TOP_RIGHT if same_chip?(rightX, topY, no, map_chipset_no, map_data)
      subNo2 |= ChipPositionType::RIGHT_BOTTOM if same_chip?(rightX, bottomY, no, map_chipset_no, map_data)
      subNo2 |= ChipPositionType::BOTTOM_LEFT if same_chip?(leftX, bottomY, no, map_chipset_no, map_data)

      #subNo1 |= ChipPositionType::LEFT | ChipPositionType::TOP | ChipPositionType::BOTTOM | ChipPositionType::LEFT

      self.render_chip(s, x * @chip_size - dx, y * @chip_size - dy, no, subNo1, subNo2)
    end
    
    def render_sample(s, x, y, map_chip_no)
      s.render_texture(
        @texture, 
        x * @chip_size, 
        y * @chip_size, 
        :src_x => (3 * map_chip_no) * @chip_size + @one, 
        :src_y => 0, :src_width => @one, 
        :src_height => @one
      )
    end
  end
end
