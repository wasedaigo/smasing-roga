require  "lib/Rectangle"
require  "scenes/map/collision_type"
require  "scenes/map/config"
require  "d_input"

class Character
  include Config

  attr_reader :x, :y, :mapX, :mapY, :id
  def initialize(character_chip, id, mapX, mapY, speed, allow_diagonal_movement = false)

    @id = id

    # Character position on map
    @mapX = mapX
    @mapY = mapY

    #Whether this character do a diagonal movement or not
    @allow_diagonal_movement = allow_diagonal_movement

    #Selected character_chipset
    @character_chip = character_chip

    #Character's position
    @x = @mapX * GRID_SIZE
    @y = @mapY * GRID_SIZE

    #Movable Distance at once
    @movableDistance = GRID_SIZE
    @movedDistance = 0

    # Character's moving speed
    @speed = speed

    # Character's animation frame No
    @defaultFrame = 1
    @frame = @defaultFrame
    @frameCounter = 0
    @frameChangeCount = 16/@speed

    # Frame change direction(to right = 1, to left = -1)
    @a = 1

    # Character's direction
    @dirX = 0
    @dirY = -1

    # Move Direction
    @moveX = 0
    @moveY = 0
  end

  def centerX
    renderX + self.width / 2
  end

  def centerY
    renderY + self.height / 2
  end

  def renderX
    @x - @character_chip.hitRect.left
  end

  def renderY
    @y - @character_chip.hitRect.top
  end

  def hitRect
    Rectangle.new @x + @character_chip.hitRect.left, @y + @character_chip.hitRect.top, @character_chip.hitRect.width, @character_chip.hitRect.height
  end

  def width
    @character_chip.sizeX
  end

  def height
    @character_chip.sizeY
  end

  def movable? map

    # hit direction for the chip where the character exists
    dir1 = 0
    dir1 += CollisionType::RIGHT if @moveX > 0
    dir1 += CollisionType::LEFT if @moveX < 0
    dir1 += CollisionType::DOWN if @moveY > 0
    dir1 += CollisionType::UP if @moveY < 0

    # hit direction for the chip where the character is going to go
    dir2 = 0
    dir2 += CollisionType::LEFT if @moveX > 0
    dir2 += CollisionType::RIGHT if @moveX < 0
    dir2 += CollisionType::UP if @moveY > 0
    dir2 += CollisionType::DOWN if @moveY < 0

    if @moveX != 0 && @moveY != 0
      # hit direction for the chip where the character is going to go
      dir3 = 0
      dir3 += CollisionType::LEFT if @moveX > 0
      dir3 += CollisionType::RIGHT if @moveX < 0
      dir3 += CollisionType::DOWN if @moveY > 0
      dir3 += CollisionType::UP if @moveY < 0

      # hit direction for the chip next to the chip where the character is going to go
      dir4 = 0
      dir4 += CollisionType::RIGHT if @moveX > 0
      dir4 += CollisionType::LEFT if @moveX < 0
      dir4 += CollisionType::UP if @moveY > 0
      dir4 += CollisionType::DOWN if @moveY < 0

      (map.obstacle? @mapX, @mapY, dir1)|| (map.obstacle? @mapX + @moveX, @mapY, dir3) || (map.obstacle? @mapX, @mapY + @moveY, dir4)||  (map.obstacle? @mapX + @moveX, @mapY + @moveY, dir2)
    else
      (map.obstacle? @mapX, @mapY, dir1 ) || (map.obstacle? @mapX + @moveX, @mapY + @moveY, dir2)
    end

  end

  def collide map

    return if @moveX == 0 && @moveY == 0

    if self.movable? map
      @moveX = 0
      @moveY = 0
    else
      @mapX += @moveX
      @mapY += @moveY
    end

  end

  def move(map)

    # before move finish the collision process
    if @firstMove
      map.set_object_collision(@mapX, @mapY, map.get_chip_collision(@mapX, @mapY))
      self.collide(map)
      map.set_object_collision(@mapX, @mapY, CollisionType::ALL)
    end

    # when there is no movement, reset the frame
    if @moveX == 0 && @moveY == 0:
      @frame = @defaultFrame
      return
    end

    # Move character
    case @moveX
    when -1
      @x -= @speed
    when 1
      @x += @speed
    end

    case @moveY
    when -1
      @y -= @speed
    when 1
      @y += @speed
    end

    # Frame Animation
    if @moveX != 0 || @moveY != 0
      @frameCounter += 1
      if @frameCounter >= @frameChangeCount
        @frameCounter = 0
        if @frame == (@character_chip.animeFrameNum - 1) || @frame == 0
          @a *= -1
        end
        @frame += @a
      end
      @movedDistance += @speed
    end

    if @movedDistance >= GRID_SIZE
      @moveX = 0
      @moveY = 0
      @movedDistance -= GRID_SIZE
    end
  end

  def set_movement(keys)
    @firstMove = false

    # Set Character Movement
    if @moveX == 0 && @moveY == 0:
      @firstMove = true
      keys.each do |key|
        self.set_movement_each_key(key)
      end
    end
  end

  def set_movement_each_key(key)
    if !@allow_diagonal_movement
      @moveX = 0
      @moveY = 0
    end

    case key
    when :up
      @dirX = 0
      @dirY = -1
      @moveY = -1
    when :right
      @dirX = 1
      @dirY = 0
      @moveX = 1
    when :down
      @dirX = 0
      @dirY = 1
      @moveY = 1
    when :left
      @dirX = -1
      @dirY = 0
      @moveX = -1
    end
  end

  # Do character's task
  def update map
    if @moveX == 0 && @moveY == 0
      if DInput.pressed? :ok
        tx = @mapX + @dirX
        ty = @mapY + @dirY
        if map.get_object_id(tx, ty) == 1
          return true
        end

      end
    end

    return false
  end

  def render(s, baseX, baseY)
    @dir = 0 if @dirY < 0
    @dir = 1 if @dirX > 0
    @dir = 2 if @dirY > 0
    @dir = 3 if @dirX < 0

    @character_chip.render s, renderX - baseX, renderY - baseY, @frame, @dir
  end

end
