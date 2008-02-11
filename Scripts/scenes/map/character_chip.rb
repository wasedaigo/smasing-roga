module SRoga
  class CharacterChip

    def initialize characterChipset,srcX, srcY
      @srcX = srcX
      @srcY = srcY
      @characterChipset = characterChipset
    end

    def render(s, x, y, frame, dir)
      s.render_texture @characterChipset.texture, x, y , {:src_x => @characterChipset.sizeX * (frame + @srcX * animeFrameNum), :src_y=>@characterChipset.sizeY * (dir + @srcY * dirNum),  :src_width => sizeX, :src_height => sizeY}
    end

    def animeFrameNum
      @characterChipset.animeFrameNum
    end

    def dirNum
      @characterChipset.dirNum
    end

    def sizeX
      @characterChipset.sizeX
    end

    def sizeY
      @characterChipset.sizeY
    end

    def hitRect
      @characterChipset.hitRect
    end
  end
end
