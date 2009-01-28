module DGO
  module TileMap
    module CharacterSpeedType
      VERY_SLOW = 1
      SLOW = 2
      NORMAL = 4
      FAST = 8
      VERY_FAST = 16
      ARR = [VERY_SLOW, SLOW, NORMAL, FAST, VERY_FAST]
      def self.[](index)
        return ARR[index]
      end
      
      def self.max
        return ARR.length - 1
      end
    end
  end
end

