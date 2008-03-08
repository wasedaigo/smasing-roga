require "scenes/map/palet_chip"
require "scenes/map/chip_position_type"

module SRoga
  class AutoPaletChip < PaletChip

    attr_reader :chipset, :sx, :sy, :collision_data, :sub1, :sub2
    def initialize(chipset, chip_no, width, collision_data)
      super(chipset, chip_no, width, collision_data)
      @half = 0.5 * self.chip_size
      @one = self.chip_size
      @double = 2 * self.chip_size
      @double_half = 2.5 * self.chip_size
      @triple = 3 * self.chip_size
      @triple_half = 3.5 * self.chip_size
    end
    
    # Property
    def chip_size
      return @chipset.chip_size
    end

    def texture
      return @chipset.texture
    end
    
    #
    # Render
    #
    def renderTopRight(s, tsx, tsy, tx, ty, no)
      return if (no & ChipPositionType::TOP_RIGHT) == ChipPositionType::TOP_RIGHT
      s.render_texture(self.texture, tx + 0.75 * self.chip_size, ty, :src_x => tsx + 2.75 * self.chip_size, :src_y => tsy + 0,  :src_width=>self.chip_size / 4, :src_height=>self.chip_size / 4)
    end

    def renderTopLeft(s, tsx, tsy, tx, ty, no)
      return if (no & ChipPositionType::TOP_LEFT) == ChipPositionType::TOP_LEFT
      s.render_texture(self.texture, tx, ty, :src_x => tsx + 2 * self.chip_size, :src_y => tsy + 0,  :src_width=>self.chip_size / 4, :src_height=>self.chip_size / 4)
    end

    def renderRightBottom(s, tsx, tsy, tx, ty, no)
      return if (no & ChipPositionType::RIGHT_BOTTOM) == ChipPositionType::RIGHT_BOTTOM
      s.render_texture(self.texture, tx + 0.75 * self.chip_size, ty + 0.75 * self.chip_size, :src_x => tsx + 2.75 * self.chip_size, :src_y => tsy + 0.75 * self.chip_size,  :src_width=>self.chip_size / 4, :src_height=>self.chip_size / 4)
    end

    def renderBottomLeft(s, tsx, tsy, tx, ty, no)
      return if (no & ChipPositionType::BOTTOM_LEFT) == ChipPositionType::BOTTOM_LEFT
      s.render_texture(self.texture, tx, ty + 0.75 * self.chip_size, :src_x => tsx + 2 * self.chip_size, :src_y => tsy + 0.75 * self.chip_size,  :src_width=>self.chip_size / 4, :src_height=>self.chip_size / 4)
    end
    
    # render chips by auto complete method
    def render(s, x, y, dx, dy, sub1, sub2)
      
      tx = x * self.chip_size - dx
      ty = y * self.chip_size - dy
      
      tsx = (3 * @sx) * self.chip_size
      tsy = (4 * @sy) * self.chip_size
      
      case sub1

      when ChipPositionType::TOP
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy + @triple,  :src_width => @half, :src_height => @one)
        s.render_texture(self.texture, tx + @half, ty, :src_x => tsx + @double_half, :src_y => tsy + @triple,  :src_width => @half, :src_height => @one)

      when ChipPositionType::RIGHT
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy + @one,  :src_width => self.chip_size, :src_height => @half)
        s.render_texture(self.texture, tx, ty + @half, :src_x => tsx, :src_y => tsy + @triple_half,  :src_width => @one, :src_height => @half)

      when ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy +@one,  :src_width => @half, :src_height=>self.chip_size)
        s.render_texture(self.texture, tx + @half, ty, :src_x => tsx + @double_half, :src_y => tsy +self.chip_size,  :src_width => @half, :src_height=>self.chip_size)

      when ChipPositionType::LEFT
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @double, :src_y => tsy + @one,  :src_width => @one, :src_height => @half)
        s.render_texture(self.texture, tx, ty + @half, :src_x => tsx + @double, :src_y => tsy + @triple_half,  :src_width => @one, :src_height => @half)

      when ChipPositionType::TOP | ChipPositionType::RIGHT
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy + @triple,  :src_width => @one, :src_height => @one)
        renderTopRight(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::TOP | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy + @double,  :src_width => @half, :src_height=>self.chip_size)
        s.render_texture(self.texture, tx + @half, ty, :src_x => tsx + @double_half, :src_y => tsy + @double,  :src_width => @half, :src_height => self.chip_size)

      when ChipPositionType::TOP | ChipPositionType::LEFT
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @double, :src_y => tsy + @triple,  :src_width => @one, :src_height => @one)
        renderTopLeft(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx , :src_y => tsy + @one,  :src_width => @one, :src_height => @one)
        renderRightBottom(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::RIGHT | ChipPositionType::LEFT
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @one, :src_y => tsy + @one,  :src_width => @one, :src_height => @half)
        s.render_texture(self.texture, tx, ty + @half, :src_x => tsx + @one, :src_y => tsy + @triple_half,  :src_width => @one, :src_height => @half)

      when ChipPositionType::BOTTOM | ChipPositionType::LEFT
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @double, :src_y => tsy + @one, :src_width => @one, :src_height => @one)
        renderBottomLeft(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::LEFT
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @one, :src_y => tsy + @triple, :src_width => @one, :src_height => @one)
        renderTopRight(s, tsx, tsy, tx, ty, sub2)
        renderTopLeft(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy + @double, :src_width => @one, :src_height => @one)
        renderTopRight(s, tsx, tsy, tx, ty, sub2)
        renderRightBottom(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy + @double, :src_width => @one, :src_height => @one)
        renderTopRight(s, tsx, tsy, tx, ty, sub2)
        renderRightBottom(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx, :src_y => tsy + @double, :src_width => @one, :src_height => @one)
        renderTopRight(s, tsx, tsy, tx, ty, sub2)
        renderRightBottom(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::TOP | ChipPositionType::LEFT | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @double, :src_y => tsy + @double, :src_width => @one, :src_height => @one)
        renderTopLeft(s, tsx, tsy, tx, ty, sub2)
        renderBottomLeft(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::RIGHT | ChipPositionType::LEFT | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @one, :src_y => tsy + @one, :src_width => @one, :src_height => @one)
        renderRightBottom(s, tsx, tsy, tx, ty, sub2)
        renderBottomLeft(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::TOP | ChipPositionType::RIGHT | ChipPositionType::LEFT | ChipPositionType::BOTTOM
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @one, :src_y => tsy + @double, :src_width => @one, :src_height => @one)
        renderTopLeft(s, tsx, tsy, tx, ty, sub2)
        renderTopRight(s, tsx, tsy, tx, ty, sub2)
        renderRightBottom(s, tsx, tsy, tx, ty, sub2)
        renderBottomLeft(s, tsx, tsy, tx, ty, sub2)

      when ChipPositionType::NONE
        s.render_texture(self.texture, tx, ty, :src_x => tsx + @one, :src_y => tsy + 0, :src_width => @one, :src_height => @one)
      end
    end

    # check the chip at optional position
    # def same_chip?(x, y, no, map_chipset_no, map_data)
      # if map_data.exists?(x, y)
        # return ChipData.equal?(map_data[x, y], map_chipset_no, no)
      # else
        # return false
      # end
    # end

    def get_subs(tx, ty, map_data)
      left_x = tx - 1
      middle_x = tx
      right_x = tx + 1

      top_y = ty - 1
      middle_y = ty
      bottom_y = ty + 1
      
      left_top = map_data.exists?(left_x, top_y) ? map_data[left_x, top_y].palet_chip : nil
      middle_top = map_data.exists?(middle_x, top_y) ? map_data[middle_x, top_y].palet_chip : nil
      right_top = map_data.exists?(right_x, top_y) ? map_data[right_x, top_y].palet_chip : nil

      left_middle = map_data.exists?(left_x, middle_y) ? map_data[left_x, middle_y].palet_chip : nil
      middle_middle = map_data.exists?(middle_x, middle_y) ? map_data[middle_x, middle_y].palet_chip : nil
      right_middle = map_data.exists?(right_x, middle_y) ? map_data[right_x, middle_y].palet_chip : nil
      
      left_bottom = map_data.exists?(left_x, bottom_y) ? map_data[left_x, bottom_y].palet_chip : nil
      middle_bottom = map_data.exists?(middle_x, bottom_y) ? map_data[middle_x, bottom_y].palet_chip : nil
      right_bottom = map_data.exists?(right_x, bottom_y) ? map_data[right_x, bottom_y].palet_chip : nil

      sub1 = 0
      sub1 |= ChipPositionType::TOP if self == middle_top
      sub1 |= ChipPositionType::RIGHT if self == right_middle
      sub1 |= ChipPositionType::BOTTOM if self == middle_bottom
      sub1 |= ChipPositionType::LEFT if self == left_middle

      sub2 = 0
      sub2 |= ChipPositionType::TOP_LEFT if self == left_top
      sub2 |= ChipPositionType::TOP_RIGHT if self == right_top
      sub2 |= ChipPositionType::RIGHT_BOTTOM if self == right_bottom
      sub2 |= ChipPositionType::BOTTOM_LEFT if self == left_bottom

      return sub1, sub2
    end
  end
end
