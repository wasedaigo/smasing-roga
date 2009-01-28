require "dgo/geometry/rectangle"
require "dgo/interval/interval_runner"
require "dgo/interval/sequence"
require "dgo/interval/parallel"
require "dgo/interval/func"
require "dgo/interval/wait"
require "dgo/interval/lerp"
require "dgo/interval/loop"

module DGO
  module TileMap
    class Character
      include DGO::Geometry
      include DGO::Interval
      include DGO::TileMap

      attr_reader :map_x, :map_y, :id, :wait, :chipset, :sx, :sy
      attr_accessor :pause, :alpha, :visible, :layer, :dir_x, :dir_y, :frame_no
      attr_accessor :offset_x, :offset_y, :hit_x, :hit_y
      attr_accessor :pass_tile, :pass_character, :pass_event, :dir_fix, :stay_anime, :move_anime
      #
      # * Initialize character
      #    chip                  : Character Chipset
      #    id                                          : Selected character ID
      #    map_x                                  : characters map position x
      #    map_y                                   : characters map position y
      #    speed                                    : amount of movement character does each frame
      #    allow_diagonal_movement : Allow movement in diagonal directino
      #
      def initialize(map, chipset, sx, sy, id, map_x, map_y, allow_diagonal_movement = false)
        self.set_chip(chipset, sx, sy)
        @map = map
        @id = id
        @map_x = map_x
        @map_y = map_y
        @allow_diagonal_movement = allow_diagonal_movement
        
        @x = @map_x * @map.grid_width
        @y = @map_y * @map.grid_height

        @hit_x = 1
        @hit_y = 1
        @offset_x = 0
        @offset_y = 0
        @sx = sx
        @sy = sy
        
        # Options
        @pass_character = true
        @pass_tile = true
        @pass_event = true
        @dir_fix = false
        @stay_anime = false
        @move_anime = false
        
        #@sprite = Sprite.new(nil, self.screen_x, self.screen_y, :src_width => self.width, :src_height => self.height)
        @speed_type = 0
        @speed = CharacterSpeedType::SLOW
        @layer = 1
        @wait = 0
        @alpha = 255
        @visible = true
        @a = 1 # Frame change direction(to right = 1, to left = -1)
        @dir_x = 0 # Character's direction x
        @dir_y = -1 # Character's direction y
        
        @move_runner = IntervalRunner.new(Sequence.new)
        @wait_runner = IntervalRunner.new(Sequence.new)
        
        @commands = []
        @checked = []
        @touched = []
        @pause = false
        

        @walk_counter = 0
        @walk_anime_dir = 1
        @frame_no = 0
      end
      #
      # * Set character position
      # 
      def set_position(map_x, map_y)
        @map_x = map_x
        @map_y = map_y
        reset_position
      end
      
      #
      # * Set character chipset
      #
      def set_chip(chipset, sx, sy)
        chipset = CharacterChipset.new(nil, nil, 16, 16, 1, 1) unless chipset
        @chipset = chipset

        @sx = sx
        @sy = sy

        #@sprite.swap_texture(chip.texture)
        #@sprite.src_width = self.width
        #@sprite.src_height = self.height
      end
      #
      # * Character center x-coordinate
      #
      def center_x
        self.screen_x + self.width / 2
      end
      #
      # * Character center y-coordinate
      #
      def center_y
        self.screen_y + self.height / 2
      end
      #
      # * Character render x-coordinate
      #
      def screen_x
        return @x - (self.width % @map.grid_width) / 2 + @offset_x * @map.grid_width
      end
      #
      # * Character render y-coordinate
      #
      def screen_y
        return @y + @map.grid_height - self.height + @offset_y * @map.grid_height
      end
      #
      # * Character systematic x-coordinate
      #
      def x
        return @x
      end
      #
      # * Character systematic y -coordinate
      #
      def y 
        return @y
      end
      #
      # * Character hit area
      #
      def hit_rect
        Rectangle.new(self.x + @chipset.hit_rect.left, self.y + @chipset.hit_rect.top, @chipset.hit_rect.width, @chipset.hit_rect.height)
      end
      #
      # * Character width
      #
      def width
        if @chipset
          return @chipset.size_x
        else
          return @map.grid_width
        end
      end
      #
      # * Character height
      #
      def height
        if @chipset
          return @chipset.size_y
        else
          return @map.grid_height
        end
      end
      #
      # * Set transparency
      #
      def alpha=(value)
        @alpha = value
      end
      #
      # * Character's speed type
      #
      def speed_type
        return @speed_type
      end
      
      def speed_type=(type)
        @speed_type = type
        @speed_type = 0 if @speed_type < 0
        @speed_type = CharacterSpeedType.max if @speed_type >= CharacterSpeedType.max
        @speed = CharacterSpeedType[@speed_type]
      end
      #
      # * Divide character direction into dx, dy
      #
      def devide_dir(dir)
        dx, dy = 0, 0
        case dir
          when 0: dy = -1
          when 1: dx = 1
          when 2: dy = 1
          when 3: dx = -1
        end
        return dx, dy
      end
      #
      # * Character direction from dx, dy
      #
      def get_dir(dx, dy)
        return 1 if @dir_x > 0
        return 3 if @dir_x < 0
        return 2 if @dir_y > 0
        return 0 if @dir_y < 0
        return 0
      end
      #
      # * Set character's direction
      #
      def set_dir(dir)
        @dir_x, @dir_y = self.devide_dir(dir)
      end
      #
      # * Set character's direction facing to target
      #
      def face_to(target)
        tx = target.map_x - self.map_x
        @dir_x = 0
        @dir_y = 0
        @dir_x = 1 if tx > 0
        @dir_x = -1 if tx < 0
        ty = target.map_y - self.map_y
        @dir_y = 1 if ty > 0
        @dir_y = -1 if ty < 0
        if tx.abs > ty.abs
          @dir_y = 0
        else
          @dir_x = 0
        end
      end
      #
      # * Character direction
      #
      def get_current_dir
        return get_dir(@dir_x, @dir_y)
      end
      #
      # * Whether the chracte can go through selected tile or not
      #   map       : map object
      #   vx         : x component of character speed
      #   vy         : y component of character speed
      #
      def passable?(vx, vy)
        # hit direction for the chip where the character exists
        dir1 = 0
        dir1 += CollisionType::RIGHT if vx > 0
        dir1 += CollisionType::LEFT if vx < 0
        dir1 += CollisionType::DOWN if vy > 0
        dir1 += CollisionType::UP if vy < 0
        # hit direction for the chip where the character is going to go
        dir2 = 0
        dir2 += CollisionType::LEFT if vx > 0
        dir2 += CollisionType::RIGHT if vx < 0
        dir2 += CollisionType::UP if vy > 0
        dir2 += CollisionType::DOWN if vy < 0
        if vx != 0 && vy != 0
          # hit direction for the chip where the character is going to go
          dir3 = 0
          dir3 += CollisionType::LEFT if vx > 0
          dir3 += CollisionType::RIGHT if vx < 0
          dir3 += CollisionType::DOWN if vy > 0
          dir3 += CollisionType::UP if vy < 0
          # hit direction for the chip next to the chip where the character is going to go
          dir4 = 0
          dir4 += CollisionType::RIGHT if vx > 0
          dir4 += CollisionType::LEFT if vx < 0
          dir4 += CollisionType::UP if vy > 0
          dir4 += CollisionType::DOWN if vy < 0
          !((@map.obstacle?(self, @map_x, @map_y, dir1))|| (@map.obstacle?(self, @map_x + vx, @map_y, dir3)) || (@map.obstacle?(self, @map_x, @map_y + vy, dir4))||  (@map.obstacle?(self, @map_x + vx, @map_y + vy, dir2)))
        else
          !((@map.obstacle?(self, @map_x, @map_y, dir1)) || (@map.obstacle?(self, @map_x + vx, @map_y + vy, dir2)))
        end
      end
      #
      # * Character Interval Running?
      #
      def running?
        return !(@move_runner.done? && @wait_runner.done?)
      end

      #
      # * Character Movement
      #   time      : require frame to execute this interval
      #   vx         : x component of character speed
      #   vy         : y component of character speed
      #
      def move_interval(time, vx, vy)
        tx = 0
        ty = 0
        Parallel.new(
          Func.new do
            tx = @x
            ty = @y
          end,
          Lerp.new(time, 0, vx * time) do |v|
            @x = v + tx
          end,
          Lerp.new(time, 0, vy * time) do |v|
            @y = v + ty
          end
        )
      end
      #
      # * Character Walk
      #
      def walk_interval(time, vx, vy)
        Parallel.new(
          self.move_interval(time, vx, vy)
        )
      end
      #
      # * Collision between character and map
      #
      def collide(vx, vy)
        if !self.passable?(vx, vy)
          vx = 0
          vy = 0
        end
        return vx, vy
      end
      #
      # * Check character state
      #
      def checked(object)
        @checked << object
      end
      #
      # * Already be checked or not
      #
      def checked?(object)
        return @checked.include?(object)
      end
      #
      # * Get current direction
      #
      def dir
        return self.get_dir(self.dir_x, self.dir_y)
      end
      #
      # * Check character state
      #
      def touched(object)
        @touched << object
      end
      #
      # * Already be checked or not
      #
      def touched?(object)
        return @touched.include?(object)
      end
      #
      # * Reset character state
      #
      def reset
        @checked.clear
        @touched.clear
      end
      #
      # * Character Update
      #     map       : map object
      #     keys      :input keyboard keys
      #
      def update
        self.animate
        @move_runner.update
        @wait_runner.update
      end
      
      def animate
        if @speed <= 8 && (@stay_anime || (!@move_runner.done? && @move_anime))
          @walk_counter += 1
          if @walk_counter >= (8 / @speed)
            @walk_counter = 0
            t = @frame_no + @walk_anime_dir
            if t < 0 || t >= @chipset.animation_frame_number 
              @walk_anime_dir *= -1
            end
            @frame_no += @walk_anime_dir
          end
        else
          if @move_anime
            if @frame_no >  @chipset.default_frame_no
              @walk_anime_dir = -1
            else
              @walk_anime_dir = 1
            end
            @frame_no = @chipset.default_frame_no
            @walk_counter = 0
          end
        end
      end
      #
      # * Input keys
      #     keys      :input keyboard keys
      #
      def input_keys(keys)
          return if self.running?
          return if @pause
          
          vx, vy = 0, 0
          keys.each do |key|
            case key
              when :up: vy = -1
              when :down: vy = 1
              when :left: vx = -1
              when :right: vx = 1
            end
          end
          
          self.set_movement(vx, vy)
      end
      #
      # *  Set character's Wait
      #     wait : integer
      def set_wait(wait)
        @wait_runner.set_interval(Wait.new(wait))
      end
      #
      # *  Set character's Movement
      #     command      :Command Object(Array)
      #
      def set_movement(vx, vy, options = {})
        return false if vx == 0 && vy == 0
        vx = 1 if vx > 1
        vy = 1 if vy > 1
        unless @dir_fix
          @dir_x, @dir_y = 0, -1 if vy == -1
          @dir_x, @dir_y = 0, 1 if vy == 1
          @dir_x, @dir_y = -1, 0 if vx == -1
          @dir_x, @dir_y = 1, 0 if vx == 1
        end
        @map.remove_object(@map_x, @map_y, self)
        #@map.set_object_collision(@map_x, @map_y, @map.get_chip_collision(@map_x, @map_y))
        t, vy = self.collide(0, vy)
        vx, t = self.collide(vx, 0)
        vx, vy = self.collide(vx, vy)
        
        #@map.set_object_collision(@map_x + vx, @map_y + vy, CollisionType::ALL)
        if vx == 0 && vy  ==0
          @map.set_object(@map_x, @map_y, self)
          @move_runner.update unless @move_runner.done?
          return false
        else
          @map_x += vx
          @map_y += vy
          t = self.walk_interval(@map.grid_width / @speed, vx * @speed, vy * @speed)
          
          touch_interval = Func.new do
            t = @map.get_object(@map_x, @map_y)
            t.touched(self) if t
          end
          if(options[:after_interval])
            s = Sequence.new(t, touch_interval, options[:after_interval])
          else
            s = Sequence.new(t, touch_interval)
          end
          @move_runner.set_interval(s)
          @map.set_object(@map_x, @map_y, self)
          @move_runner.update unless @move_runner.done?
          return true
        end
       
      end
      #
      # * Reset Character
      #
      
      def reset_position
        #@pause = false
        @move_runner.clear
        @wait_runner.clear
        @x = @map_x * @map.grid_width
        @y = @map_y * @map.grid_height
      end
      #
      # * Render Character
      #      s       : Destination Texture
      #    dx      : offset x
      #    dy      : offset y
      #
      def render(s, dx, dy)
        return unless @chipset && @visible
        
        @chipset.render(s, self.screen_x + dx, self.screen_y + dy, @sx, @sy, @frame_no, self.get_current_dir, :alpha => @alpha)
      end
    end
  end
end