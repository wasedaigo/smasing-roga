module SRoga
  class MapLayer
    attr_reader :map_data, :mapChipsetNoData

    # extra field on map texture
    EX_GRID = 1

    def initialize(map, map_data)
      @map = map
      @map_data = map_data
      self.refresh_texture
    end

    def refresh_texture
      tw = (@map.show_w_count + EX_GRID) * @map.grid_size
      th = (@map.show_h_count + EX_GRID) * @map.grid_size
      t = Texture.new(tw, th)
      t.render_texture(@texture, 0, 0) unless @texture.nil?
      @texture = t
      @buffer = Texture.new(tw, th)
    end
    
    def width
      @map.grid_size * @map_data.width
    end

    def height
      @map.grid_size * @map_data.height
    end

    def abs(value)
      if value < 0
        -1 * value
      else
        value
      end
    end

    def clear_rect(sx, sy, w, h)
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
      
      if sx + w >= @map_data.width || sy + h >= @map_data.height || w + tx <= 0 || h + ty <= 0
        return
      end
      
      tw = (w + tx) * @map.grid_size
      th = (h + ty) * @map.grid_size
      sx = sx * @map.grid_size
      sy = sy * @map.grid_size
      
      if sx + tw > @texture.width
        tw = @texture.width - sx
      end

      if sy + th > @texture.height
        th = @texture.height - sy
      end
      
      if tw <= 0 || th <= 0
        return
      end

      if(@base)
        @texture.fill_rect(sx, sy, tw, th, Color.new(0,0,0,255))
      else
        @texture.fill_rect(sx, sy, tw, th, Color.new(0,0,0,0))
      end
    end
    
    def render_new_part(rx, ry, sx, sy, w, h)
      # render all visible map chips

      #p "rx #{rx} ry #{ry} w #{w} h #{h}"

      self.clear_rect(rx, ry, w, h)

      (0..([sx + w, @map_data.width].min - sx - 1)).each do |x|
        (0..([sy + h, @map_data.height].min - sy - 1)).each do |y|
          map_chip = @map_data[sx + x, sy + y]
          unless(map_chip.palet_chip.chip_no == 0)
            map_chip.palet_chip.render(@texture, rx + x, ry + y, 0, 0, map_chip.sub1, map_chip.sub2)
          end
        end
      end
      #p i.to_s
    end

    def update(sx, sy, w, h, dx, dy)
      #p "TES + #{sx},#{sy},#{w},#{h},#{dx},#{dy}"
      
      tw = w + EX_GRID
      th = h + EX_GRID
      #@texture.clear
      if abs(dx) >= tw || abs(dy) >= th
        render_new_part(0, 0, sx, sy, tw, th)
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

        # reuse texture where can be used
        @buffer.clear
        @buffer.render_texture(@texture, tx1 * @map.grid_size, ty1 * @map.grid_size, :src_x => tx2 * @map.grid_size, :src_y => ty2 * @map.grid_size, :src_width => (tw - abs(dx)) * @map.grid_size, :src_height => (th - abs(dy)) * @map.grid_size)
        
        # swap buffer and texture
        t = @texture
        @texture = @buffer
        @buffer = t

        # render new area
        render_new_part(tw - dx, 0, sx + tw - dx, sy, dx, th) if dx > 0 # Right
        render_new_part(0, 0, sx, sy, -dx, th)  if dx < 0 #Left
        render_new_part(0, th - dy, sx, sy + th - dy, tw, dy) if dy > 0 #Bottom
        render_new_part(0, 0, sx, sy, tw, -dy) if dy < 0 #Top
      end
    end

    def update_complementary_data(rx, ry, sx, sy, w, h)
          # set complementary values
          (0..([sx + w, @map_data.width].min - sx - 1)).each do |x|
            (0..([sy + h, @map_data.height].min - sy - 1)).each do |y|
              map_chip = @map_data[sx + x, sy + y]
              map_chip.sub1, map_chip.sub2 = map_chip.palet_chip.get_subs(sx + x, sy + y, @map_data)
            end
          end
    end
          
    def render(s, dx, dy, options = {})
        options[:src_x] = (options[:src_x].nil?) ? dx : dx + options[:src_x]
        options[:src_y] = (options[:src_y].nil?) ? dy : dy + options[:src_y]
        options[:src_width] = (options[:src_width].nil?) ? @texture.width - dx : options[:src_width]
        options[:src_height] = (options[:src_height].nil?) ? @texture.height - dy : options[:src_height]
        s.render_texture(@texture, 0, 0, options)
    end
  end
end
