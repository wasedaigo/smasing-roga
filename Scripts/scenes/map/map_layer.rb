require  "scenes/map/config"

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
      t = Texture.new((@map.show_w_count + EX_GRID) * Config::GRID_SIZE, (@map.show_h_count + EX_GRID) * Config::GRID_SIZE)
      t.render_texture(@texture, 0, 0) unless @texture.nil?
      @texture = t
    end
    
    def width
      Config::GRID_SIZE * @map_data.width
    end

    def height
      Config::GRID_SIZE * @map_data.height
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
      
      tw = (w + tx) * Config::GRID_SIZE
      th = (h + ty) * Config::GRID_SIZE
      sx = sx * Config::GRID_SIZE
      sy = sy * Config::GRID_SIZE
      
      if sx + tw > @texture.width
        tw = @texture.width - sx
      end

      if sy + th > @texture.height
        th = @texture.height - sy
      end
      
      if tw <= 0 || th <= 0
        return
      end

      @texture.fill_rect(sx, sy, tw, th, Color.new(0,0,0,0))
    end
    
    def render_new_part(rx, ry, sx, sy, w, h)
      # render all visible map chips
<<<<<<< .mine
      #p "rx #{rx} ry #{ry} w #{w} h #{h}"
=======
      
>>>>>>> .theirs
      self.clear_rect(rx, ry, w, h)

      (0..([sx + w, @map_data.width].min - sx - 1)).each do |x|
        (0..([sy + h, @map_data.height].min - sy - 1)).each do |y|
          map_chip = @map_data[sx + x, sy + y]
          map_chip.palet_chip.render(@texture, rx + x, ry + y, 0, 0, map_chip.sub1, map_chip.sub2)
<<<<<<< .mine










=======
        (0..([sy + h, @map_data.height].min - sy - 1)).each do |y|
          tx = sx + x
          ty = sy + y
          #if @map_data.exists?(tx, ty)
          map_chipset_no = ChipData.get_map_chipset_no(@map_data[tx, ty])
          m = @map.map_chipsets[map_chipset_no]
          
          m.render(@texture, rx + x, ry + y, 0, 0, tx, ty, map_chipset_no, @map_data)
          i += 1
          #end
>>>>>>> .theirs
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
        @texture.render_texture(@texture, tx1 * Config::GRID_SIZE, ty1 * Config::GRID_SIZE, :src_x => tx2 * Config::GRID_SIZE, :src_y => ty2 * Config::GRID_SIZE, :src_width => (tw - abs(dx)) * Config::GRID_SIZE, :src_height => (th - abs(dy)) * Config::GRID_SIZE)

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
        options.merge!(:src_x => dx, :src_y => dy, :src_width => @texture.width - dx, :src_height => @texture.height - dy)
        s.render_texture(@texture, 0, 0, options)
    end
  end
end
