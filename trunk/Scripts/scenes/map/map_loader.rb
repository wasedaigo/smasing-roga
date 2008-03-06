require  "scenes/map/collision_type"

  module SRoga
  module MapLoader

    def self.loadMap

      # load map chip counts(width & height)
      wCount = 80
      hCount = 80
      
      # load bottom layer
      t = Array.new(wCount * hCount)
      t.each_with_index do |obj, i|
      #v = 1 if rand(4) == 0
        t[i] = ChipData.generate(0, 0)
        if(i % wCount == 0 || i % wCount == wCount - 1 || i / wCount == 0 || i / wCount == hCount - 1)
          t[i] = ChipData.generate(0, 6)
        end
      end
      bottomLayer = Table.new(wCount, t)

      # load top layer
      t = Array.new(wCount * hCount)
      t.each_with_index do |obj, i|
        t[i] = ChipData.generate(0, 0)
        if(i % wCount == 0 || i % wCount == wCount - 1 || i / wCount == 0 || i / wCount == hCount - 1)
          t[i] = ChipData.generate(0, 6)
        end
      end
      topLayer = Table.new(wCount, t)

      # load collision data
      t = Array.new(wCount * hCount)
      bottomLayer.each_with_index do |obj, i|
        t[i] = CollisionType::NONE
        t[i] = CollisionType::ALL if ChipData.equal?(obj, 0, 1)
      end
      collisionData = Table.new(wCount, t)

      # return results
      {:wCount=>wCount, :hCount=>hCount, :topLayer=>topLayer, :bottomLayer=>bottomLayer, :collisionData=>collisionData}
    end
  end
end
