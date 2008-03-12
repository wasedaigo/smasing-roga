require  "scenes/map/map_layer"
require  "scenes/map/config"

module SRoga
  class Map
    attr_reader :w_count, :h_count, :show_w_count, :show_h_count, :grid_size
    attr_accessor :base_x,:base_y

    MIN = -999999999999

    # x and y should be less than 2^BIT
    BIT = 8

    def initialize(w_count, h_count, show_w_count, show_h_count, grid_size, collision_data)
      # size restriction
      raise raise("map size have to be less than 256 * 256") if (w_count >= (1 << BIT)) || (h_count >= (1 << BIT))

      @grid_size = grid_size
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
      @grid_size * @w_count
    end

    def height
      @grid_size * @h_count
    end
    
    def show_width
      @grid_size * @show_w_count
    end

    def show_height
      @grid_size * @show_h_count
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

    def set_size(w_count, h_count, layers)
      if @w_count == w_count && @h_count == h_count
        return
      end
      @w_count = w_count
      @h_count = h_count
      self.set_show_size(w_count, h_count, layers)
    end

    def set_show_size(show_w_count, show_h_count, layers)
      tw = [show_w_count, @w_count].min
      th = [show_h_count, @h_count].min
      if @show_w_count == tw && @show_h_count == th
        return
      end

      @px = MIN
      @py = MIN
      
      @show_w_count = tw
      @show_h_count = th
      layers.each do |obj|
        obj.refresh_texture
      end
    end
    
    def update(show_w_count, show_h_count, layers)
      # Render Start Position Top Left
      sx = (@base_x/@grid_size).floor
      sy = (@base_y/@grid_size).floor

      # Render grid size
      w = show_w_count#(show_width/@grid_size).floor
      h = show_h_count#(show_height/@grid_size).floor
      
      # w = @show_w_count
      # h = @show_h_count
      
      # Render Delta
      @dx = @base_x.floor % @grid_size
      @dy = @base_y.floor % @grid_size

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
      
      #p "---------------------------------"
    end

    def render(s, layer, options = {})
      layer.render(s, @dx, @dy, options)
    end
  end
end
