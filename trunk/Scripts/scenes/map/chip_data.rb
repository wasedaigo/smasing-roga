module SRoga
  class ChipData

    # | MapChipSetNo | MapChipNo | sub1 | sub2 |
    #|           8bit        |         16bit  | 4bit  | 4bit  |

    MAPCHIPSET_NO_MASK = 255 << 24
    MAPCHIP_NO_MASK = 65535 << 8
    SUB1_MASK = 15 << 4
    SUB2_MASK = 15

    def self.generate(mapChipSetNo, mapChipNo, sub1 = 0, sub2 = 0)
      (mapChipSetNo << 24) | (mapChipNo << 8)|(sub1 << 4)|(sub2)
    end

    def self.get_map_chipset_no(value)
      (value & MAPCHIPSET_NO_MASK) >> 24
    end

    def self.get_map_chip_no(value)
      (value & MAPCHIP_NO_MASK) >> 8
    end

    def self.getSub2(value)
      (value & SUB1_NO_MASK) >> 4
    end

    def self.getSub2(value)
      (value & SUB2_NO_MASK)
    end

    def self.equal?(value, mapChipSetNo, mapChipNo)
      value == (mapChipSetNo << 24) | (mapChipNo << 8)
    end

  end
end
