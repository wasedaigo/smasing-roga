module DRPGTool
  require  "scenes/map/map"
  require  "scenes/map/map_layer"
  require  "scenes/map/map_chipset"
  require  "scenes/map/auto_map_chipset"
  require "frame"
  require "lib/table"
  
  TestMapChipset = AutoMapChipset.new("ChipSet2", 16)
  TestMapChipset2 = MapChipset.new("ChipSet", 16)

  class MapPanel < Wx::ScrolledWindow
    include Frame
    attr_reader :texture
    attr_accessor :palet, :using_palet_no
    
    def initialize(parent, id, size, palets)
      super(parent, id, Wx::Point.new(0, 0), size)
      @sx = 0
      @sy = 0
      @ex = 0
      @ey = 0
      
      @draw_sx = 0
      @draw_sy = 0
      
      @frame_w = 0
      @frame_h = 0
      
      data = MapLoader.loadMap
      @tile_w_count = data[:wCount]
      @tile_h_count = data[:hCount]
      @map_width = @tile_w_count * Config::GRID_SIZE
      @map_height = @tile_h_count * Config::GRID_SIZE
      
      @mode = :put
      @palets = palets
      @using_palet_no = 0

      @map =  Map.new(@tile_w_count, @tile_h_count, @tile_w_count, @tile_h_count, data[:collisionData], 0  => TestMapChipset, 1  => TestMapChipset2)

      @layers = [MapLayer.new(@map, data[:bottomLayer]), MapLayer.new(@map, data[:topLayer])]
      @current_layer_no = 0
      @zoom = 1
      @frame_zoom = 1
      @texture = Texture.new(@map_width, @map_height)

      #self.update_panel
      self.refresh
      evt_paint do |e|
        paint{|dc|self.on_paint(dc)}
      end
      
      evt_size do |e|
        on_size_changed(e)
      end
    
      evt_left_down do |e|
        self.on_left_down(e)
      end
      
      evt_right_down do |e|
        self.on_right_down(e)
      end
  
      evt_right_up do |e|
        self.on_right_up(e)
      end
      
      evt_motion do |e|
        self.on_motion(e)
      end
    end
    
    def change_active_layer(no)
      @current_layer_no = no
    end
    
    def current_layer
      return @layers[@current_layer_no]
    end

    def palet
      return @palets[@using_palet_no]
    end
    
    def refresh
      paint{|dc|self.on_paint(dc)}
    end

    def zoom_in
      @zoom = [4, @zoom + 1].min
      self.set_scrollbars(Config::GRID_SIZE * @zoom, Config::GRID_SIZE * @zoom, @tile_w_count, @tile_h_count, 0, 0, true)
      #self.update_panel
      self.refresh
    end
    
    def zoom_out
      @zoom = [1, @zoom - 1].max
      self.set_scrollbars(Config::GRID_SIZE * @zoom, Config::GRID_SIZE * @zoom, @tile_w_count, @tile_h_count, 0, 0, true)
      #self.update_panel
      self.refresh
    end

    def update_panel
      @map.base_x = 0
      @map.base_y = 0
      @map.update(@map_width, @map_height, [current_layer])
      @texture.clear
      @layers.each{|layer|@map.render(@texture, layer)}
  
      t_size = self.get_client_size
      return if size.x == 0

      tx, ty = self.calc_scrolled_position(0, 0)
      tw = [t_size.x, @map_width * @zoom].min
      th = [t_size.y, @map_height * @zoom].min
      ttx = -tx / @zoom
      tty = -ty / @zoom
      self.render_frame(@texture)
      @dst_texture = Texture.new(tw, th)
      @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom, :src_x => ttx, :src_y => tty, :src_width => [tw, @texture.width - ttx].min, :src_height => [th, @texture.height - tty].min)
    end

    def on_size_changed(e)
      paint{|dc|dc.clear}
      self.set_scrollbars(Config::GRID_SIZE * @zoom, Config::GRID_SIZE * @zoom, @tile_w_count, @tile_h_count, 0, 0, true)
      self.refresh
    end
    
    def on_paint(dc)
      
      self.update_panel
      tx, ty = self.calc_scrolled_position(0, 0)
      do_prepare_dc(dc)
      dc.draw_texture(@dst_texture, -tx, -ty)
    end

    def on_left_down(e)
      tx, ty = self.calc_scrolled_position(0, 0)
      sx = ((e.get_x - tx) / (Config::GRID_SIZE.to_f * @zoom)).floor
      sy = ((e.get_y - ty) / (Config::GRID_SIZE.to_f * @zoom)).floor
      @draw_sx = sx
      @draw_sy = sy
      self.put_tile(sx, sy)
    end

  	def on_motion(e)
      @mode = :put
      if e.dragging
        if e.left_is_down
          tx, ty = self.calc_scrolled_position(0, 0)
          sx = ((e.get_x - tx) / (Config::GRID_SIZE.to_f * @zoom)).floor
          sy = ((e.get_y - ty) / (Config::GRID_SIZE.to_f * @zoom)).floor
          self.put_tile(sx, sy)
        end
        if e.right_is_down
          @mode = :select
          tx, ty = self.calc_scrolled_position(0, 0)
          @ex = ((e.get_x - tx) / (Config::GRID_SIZE.to_f * @zoom)).floor
          @ey = ((e.get_y - ty) / (Config::GRID_SIZE.to_f * @zoom)).floor
        end
      end

      if @mode == :put
        self.set_default_frame(e.get_x, e.get_y)
      end

      #self.update_panel
      self.refresh
  	end
    
    def set_default_frame(x, y)
      tx, ty = self.calc_scrolled_position(0, 0)
      @sx = ((x - tx) / (Config::GRID_SIZE.to_f * @zoom)).floor
      @sy = ((y - ty) / (Config::GRID_SIZE.to_f * @zoom)).floor

      if self.palet.active?
        @ex = @sx + self.palet.frame_w - 1
        @ey = @sy + self.palet.frame_h - 1
      else
        @ex = @sx + @frame_w - 1
        @ey = @sy + @frame_h - 1
      end
    end

    def on_right_down(e)
      tx1, ty1 = self.calc_scrolled_position(0, 0)
      tx2 = ((e.get_x - tx1) / (Config::GRID_SIZE.to_f * @zoom)).floor
      ty2 = ((e.get_y - ty1) / (Config::GRID_SIZE.to_f * @zoom)).floor
      
      self.select(tx2, ty2)
      self.set_default_frame(e.get_x, e.get_y)
    end

    def on_right_up(e)
      @mode = :put
      @memory = nil
      unless self.frame_w == 1 && self.frame_h == 1
        arr = []
        (0 .. (@sy - @ey).abs).each do |ty|
          (0 .. (@sx - @ex).abs).each do |tx|
            arr << current_layer.map_data[[@sx, @ex].min + tx, [@sy, @ey].min + ty]
          end
        end

        @memory = Table.new((@sx - @ex).abs + 1, arr)
        @palets.each{|key, palet|palet.active = false}
      end
    end

    def select(x, y)

      @sx = x
      @sy = y
      @ex = @sx
      @ey = @sy

      #ChipData.get_map_chipset_no(current_layer.map_data[sx, sy])
      
      @using_palet_no = ChipData.get_map_chipset_no(current_layer.map_data[@sx, @sy])
      @palets.each{|key, palet|palet.active = false}
      self.palet.active = true
      self.palet.select_chip_by_id(ChipData.get_map_chip_no(current_layer.map_data[@sx, @sy]))
    end
  	
  	def put_tile(sx, sy)
      
      if self.palet.active?

        self.palet.each_chip_info do |id, tx, ty|
          ttx = (tx - (sx - @draw_sx) % self.palet.frame_w) % self.palet.frame_w
          tty = (ty - (sy - @draw_sy) % self.palet.frame_h) % self.palet.frame_h
          if current_layer.map_data.exists?(sx + ttx, sy + tty)
            current_layer.map_data[sx + ttx, sy + tty] = id
          end
        end

        current_layer.render_new_part(sx - 1, sy - 1, sx - 1, sy - 1, 2 + self.palet.frame_w, 2 + self.palet.frame_h)
      else
        
        @memory.each_with_two_index do |id, tx, ty|
          ttx = (tx - (sx - @draw_sx) % self.frame_w) % self.frame_w
          tty = (ty - (sy - @draw_sy) % self.frame_h) % self.frame_h
          
          if current_layer.map_data.exists?(sx + ttx, sy + tty)
            current_layer.map_data[sx + ttx, sy + tty] = id
          end
        end
        
        current_layer.render_new_part(sx - 1, sy - 1, sx - 1, sy - 1, 2 + @memory.width, 2 + @memory.height)
      end
      #self.update_panel
      self.refresh
  	end
  end
end
