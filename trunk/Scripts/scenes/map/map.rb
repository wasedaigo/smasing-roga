require  "scenes/map/map_layer"
require  "scenes/map/config"

module SRoga
  class Map
    attr_reader :map_chipsets, :w_count, :h_count, :show_w_count, :show_h_count
    attr_accessor :base_x,:base_y

    MIN = -999999999999

    # x and y should be less than 2^BIT
    BIT = 8

    def initialize(w_count, h_count, show_w_count, show_h_count, collision_data, map_chipsets)
      @map_chipsets = map_chipsets

      # size restriction
      raise raise("map size have to be less than 256 * 256") if (w_count >= (1 << BIT)) || (h_count >= (1 << BIT))

      @collision_data = collision_data

      @object_collisions = Hash.new
      @object_IDs = Hash.new

      @w_count = w_count
      @h_count = h_count

      @show_w_count = show_w_count
      @show_h_count = show_h_count

      @dx = 0
      @dy = 0

      @px = MIN
      @py = MIN

      @base_x = 0
      @base_y = 0
    end

    def getKey x, y
      return x + (y << BIT)
    end

    # Chip Collisions
    def get_chip_collision(x, y)
      return @collision_data[x, y]
    end

    # Object Collisions
    def get_object_collision(x, y)
      return @object_collisions[getKey(x, y)]
    end

    def set_object_collision(x, y, value)
      @object_collisions[getKey(x, y)] = value
    end

    def reset_object_collisions
      @object_collisions.clear
    end

    #
    # Object IDs
    #
    def get_object_id x, y
      @object_IDs[getKey(x, y)]
    end

    def set_object_id x, y, value
      @object_IDs[getKey(x, y)] = value
    end

    def reset_object_ids
      @object_IDs.clear
    end

    #
    # Map
    #
    def width
      Config::GRID_SIZE * @w_count
    end

    def height
      Config::GRID_SIZE * @h_count
    end

    def obstacle?(x, y, dir)
      if not @collision_data.exists?(x, y)
        return true
      else
        data = get_object_collision(x, y)
        data = @collision_data[x, y] if data == nil
        return data & dir != 0
      end
    end
    
    def update(show_width, show_height, layers)
      # Render Start Position Top Left
      sx = @base_x/Config::GRID_SIZE
      sy = @base_y/Config::GRID_SIZE

      # Render grid size
      w = show_width/Config::GRID_SIZE
      h = show_height/Config::GRID_SIZE

      # Render Delta
      @dx = @base_x % Config::GRID_SIZE
      @dy = @base_y % Config::GRID_SIZE

      if sx<0
        sx = 0
        @dx = 0
      end
      if sy<0
        sy = 0
        @dy = 0
      end

      if sx>= @w_count - w
        sx = @w_count - w
        @dx = 0
      end
      if sy>=@h_count - h
        sy = @h_count - h
        @dy = 0
      end
      
      if @px != sx || @py != sy
        layers.each do |obj|
          obj.update(sx, sy, w, h, sx - @px, sy - @py)
        end

        # Save current positions
        @px = sx
        @py = sy
      end
    end

    def render(s, layer)
      layer.render(s, @dx, @dy)
    end
  end
end
