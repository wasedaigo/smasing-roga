require "lib/rectangle"
class CharacterChipset
  attr_accessor  :x, :y, :sizeX, :sizeY, :animeFrameNum, :dirNum, :texture, :hitRect

  def initialize filename, sizeX, sizeY, animeFrameNum, hitRect = nil

    @sizeX = sizeX
    @sizeY = sizeY
    @animeFrameNum = animeFrameNum

    if hitRect == nil
      @hitRect = Rectangle.new(0, 0, sizeX, sizeY)
    else
      @hitRect = hitRect
    end

    @dirNum = 4

    #@dirType = dirType

    @texture = $res.get_texture(filename)
  end

  def width
    @texture.width
  end

  def height
    @texture.height
  end

  def wCount
    width / @chipSize
  end

  def hCount
    height / @chipSize
  end

end
