require "dgo/interval/interval_runner"
require "dgo/interval/lerp"
require "dgo/interval/wait"
require "dgo/tile_map/collision_type"

module DGO
  module TileMap
    class Map
      include DGO::Interval
      
      attr_reader :collision_data
      attr_reader :x_count, :y_count, :show_x_count, :show_y_count, :grid_width, :grid_height, :ex_grid
      attr_accessor :base_x,:base_y
      attr_reader :frame_no, :layer_textures

      # x and y should be less than 2^BIT
      BIT = 8
      MIN = -999999999999
      
      def initialize(x_count, y_count, show_x_count, show_y_count, grid_width, grid_height, collision_data, layer_num, layer_frame_num, render_mode, ex_grid = 1)
        # size restriction
        raise raise("map size have to be less than 256 * 256") if (x_count >= (1 << BIT)) || (y_count >= (1 << BIT))

        @ex_grid = ex_grid
        @grid_width = grid_width
        @grid_height = grid_height
        @collision_data = collision_data

        @object_collisions = {}
        @objects = {}

        @x_count = x_count
        @y_count = y_count

        @show_x_count = show_x_count
        @show_y_count = show_y_count

        @dx = 0
        @dy = 0

        @base_x = 0
        @base_y = 0
        
        @render_mode = render_mode
        
        @layer_num = layer_num
        @layer_frame_num = layer_frame_num
        
        @frame_no = 0
        time = 10
        @frame_runner = IntervalRunner.new(
          Wait.new(time * @layer_frame_num - 1) do |value|
            @frame_no = value / 10
          end
        )
                
        @layer_textures = []
        self.initialize_textures
      end

      def initialize_textures           
        @buffer = Texture.new(self.texture_width, self.texture_height)
        @layer_textures = []
        (0..(@layer_frame_num - 1)).each do |i|
          @layer_textures << {:px => MIN, :py => MIN, :textures => []}
          @layer_num.times do
            @layer_textures[i][:textures] << Texture.new(self.texture_width, self.texture_height)
          end
        end
      end
      
      def refresh_textures
        @buffer = Texture.new(self.texture_width, self.texture_height)
        @layer_textures.each do |layer_frame|
          layer_frame[:px] = MIN
          layer_frame[:py] = MIN
          layer_frame[:textures].each_with_index do |texture, i|
            t = Texture.new(self.texture_width, self.texture_height)
            t.render_texture(texture, 0, 0) unless @texture.nil?
            layer_frame[:textures][i] = t
          end
        end
        GC.start
      end
      
      def get_key(x, y)
        return x + (y << BIT)
      end
      
      # Chip Collisions
      def get_chip_collision(x, y)
        return @collision_data[x, y]
      end

      # Object Collisions
      def get_object_collision(object, x, y)
        key = get_key(x, y)
        t = nil
        t = @objects[key].find {|item| item.layer == object.layer} if @objects[key]
        if t
          return CollisionType::ALL, t
        else
          return nil, t
        end
        #return @object_collisions[get_key(x, y)]
      end

      def set_object_collision(x, y, value)
        @object_collisions[get_key(x, y)] = value
      end

      def reset_object_collisions
        @object_collisions.clear
      end

      #
      # Objects
      #
      def get_object(x, y)
        key = get_key(x, y)
        if @objects[key] && !@objects[key].empty?
          return @objects[key].last
        else
          return nil
        end
      end

      def set_object(x, y, obj)
        key = get_key(x, y)
        @objects[key] = [] if @objects[key].nil?
        @objects[key] << obj
      end
      
      def remove_object(x, y, obj)
        key = get_key(x, y)
        @objects[key] = [] if @objects[key].nil?
        @objects[key].delete(obj)
      end
      
      def reset_objects
        @objects.clear
      end

      #
      # Map
      #
      def texture_width
        (@show_x_count + @ex_grid) * @grid_width
      end
      
      def texture_height
        (@show_y_count + @ex_grid) * @grid_height
      end
      
      def width
        @grid_width * @x_count
      end

      def height
        @grid_height * @y_count
      end
      
      def show_width
        @grid_width * @show_x_count
      end

      def show_height
        @grid_height * @show_y_count
      end

      def obstacle?(object, x, y, dir)
        if not @collision_data.exists?(x, y)
          return true
        else
          data, target = get_object_collision(object, x, y)
          if data == nil || target.pass_tile
            return false if object.pass_tile
            data = @collision_data[x, y]
          else
            target.touched(object)
            return false if object.pass_character || target.pass_character
          end
          
          return data & dir != 0
        end
      end

      def set_size(x_count, y_count, layers)
        if @x_count == x_count && @y_count == y_count
          return
        end
        @x_count = x_count
        @y_count = y_count
        
        layers.each do |layer|
          layer.set_size(x_count, y_count)
        end
      end

      def set_show_size(show_x_count, show_y_count, layers)
        tw = [show_x_count, @x_count].min
        th = [show_y_count, @y_count].min
        if @show_x_count == tw && @show_y_count == th
          return
        end

        @show_x_count = tw
        @show_y_count = th
        self.refresh_textures
      end
      
      def clear_rect(texture, sx, sy, w, h)
        tx = 0
        ty = 0

        if sx < 0
          tx = sx 
          sx = 0
        end
        if sy < 0
          ty = sy
          sy = 0
        end

        if sx + w - 1 > self.x_count || sy + h - 1 > self.y_count || w + tx <= 0 || h + ty <= 0
          return
        end
        
        tw = (w + tx) * self.grid_width
        th = (h + ty) * self.grid_height
        sx = sx * self.grid_width
        sy = sy * self.grid_height
        
        if sx + tw > texture.width
          tw = texture.width - sx
        end

        if sy + th > texture.height
          th = texture.height - sy
        end

        if tw <= 0 || th <= 0
          return
        end

        texture.fill_rect(sx, sy, tw, th, Color.new(0,0,0,0))
      end

     def cariculate_update_area
        # Render Start Position Top Left
        sx = (@base_x / @grid_width).floor
        sy = (@base_y / @grid_height).floor

        # Render grid size
        w = @show_x_count
        h = @show_y_count
        
        # Render Delta
        @dx = @base_x.floor % @grid_width
        @dy = @base_y.floor % @grid_height

        if sx < 0
          sx = 0
          @dx = 0
        end
        if sy < 0
          sy = 0
          @dy = 0
        end

        if sx >= @x_count - w
          sx = @x_count - w
          @dx = 0
        end

        if sy >= @y_count - h
          sy = @y_count - h
          @dy = 0
        end
        
        return sx, sy, w, h
      end
      
      def update(layers)
        # Update animation frame
        @frame_runner.update unless @frame_runner.done?
        @frame_runner.reset if @frame_runner.done?

        sx, sy, w, h = self.cariculate_update_area
        
        self.update_layers(layers, sx, sy, w, h)
      end
      
      def get_layer_texture(layer_no, frame_no = 0)
        return @layer_textures[frame_no][:textures][layer_no]
      end
      
      def update_layers(layers, sx, sy, w, h)
        return if @layer_textures[@frame_no][:px] == sx && @layer_textures[@frame_no][:py] == sy

        dx = sx - @layer_textures[@frame_no][:px]  
        dy = sy - @layer_textures[@frame_no][:py]  
        
        
        tw = w + @ex_grid
        th = h + @ex_grid
        
        #@texture.clear
        if dx.abs >= tw || dy.abs >= th
          render_new_part(@layer_textures[@frame_no][:textures], layers, 0, 0, sx, sy, tw, th)
        else
          if dx > 0
            tx1 = 0
            tx2 = dx
          end
          if dx <= 0
            tx1 = -dx
            tx2 = 0
          end

          if dy > 0
            ty1 = 0
            ty2 = dy
          end

          if dy <= 0
            ty1 = -dy
            ty2 = 0
          end

          # Copy(reuse) prerendered texture area
          @layer_textures[@frame_no][:textures].each_with_index do |texture, i|
            @buffer.clear
            @buffer.render_texture(texture, tx1 * @grid_width, ty1 * @grid_height, :src_x => tx2 * @grid_width, :src_y => ty2 * @grid_height, :src_width => (tw - dx.abs) * @grid_width, :src_height => (th - dy.abs) * @grid_height, :mode => :none)

            # swap buffer and texture
            t = texture
            @layer_textures[@frame_no][:textures][i] = @buffer
            @buffer = t
          end

          # render new area
          render_new_part(@layer_textures[@frame_no][:textures], layers, tw - dx, 0, sx + tw - dx, sy, dx, th) if dx > 0 # Right
          render_new_part(@layer_textures[@frame_no][:textures], layers, 0, 0, sx, sy, -dx, th)  if dx < 0 #Left
          render_new_part(@layer_textures[@frame_no][:textures], layers, 0, th - dy, sx, sy + th - dy, tw, dy) if dy > 0 #Bottom
          render_new_part(@layer_textures[@frame_no][:textures], layers, 0, 0, sx, sy, tw, -dy) if dy < 0 #Top
        end
        @layer_textures[@frame_no][:px]   = sx
        @layer_textures[@frame_no][:py]   = sy
      end

      def render_new_part(textures, layers, rx, ry, sx, sy, w, h)
        textures.each do |texture|
          self.clear_rect(texture, rx, ry, w, h)
        end

        case @render_mode
        when :game
          layers.each do |layer|
            layer.render(textures, rx, ry, sx, sy, w, h)
          end

        when :editor
          layers.each_with_index do |layer, i|
            layer.render_data_layer(textures[i], rx, ry, sx, sy, w, h)
          end
        end
      end
      
      def render(s, layer_no, dx = 0, dy = 0, options = {})
        options[:src_x] = (options[:src_x].nil?) ? @dx : @dx + options[:src_x]
        options[:src_y] = (options[:src_y].nil?) ? @dy : @dy + options[:src_y]
        options[:src_width] = (options[:src_width].nil?) ? texture_width - @dx : options[:src_width]
        options[:src_height] = (options[:src_height].nil?) ? texture_height - @dy : options[:src_height]

        texture = @layer_textures[@frame_no][:textures][layer_no]
        s.render_texture(texture, dx, dy, options)
      end
    end
  end
end
