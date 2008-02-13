require "scenes/map/config"
require "scenes/map/chip_data"
require "frame"

module DRPGTool
  class PaletPanel < Wx::ScrolledWindow
    include Frame
    attr_reader :chip_id
    attr_accessor :zoom

    def initialize(parent, id, size)
      @sx = 0
      @sy = 0
      @ex = 0
      @ey = 0
      super(parent, id, Wx::Point.new(0, 0), size)
      
      @virtual_size = size
      
      @sx = 0
      @sy = 0
      @zoom = 2
      @frame_zoom = 1
      
      @chip_id = 0
      @chipset_no = 0
      @active = false

      @frame_w = 0
      @frame_h = 0
      
      @texture = Texture.new(16 * PALET_ROW_COUNT, size.get_height)
      self.refresh
      
      evt_paint do |e|
        paint{|dc|self.on_paint(dc)}
      end

      evt_size do |e|
        self.on_size_changed(e)
      end
      
      evt_left_down do |e|
        self.on_left_down(e)
      end
  
      evt_motion do |e|
        self.on_motion(e)
      end
    end
    
    def each_chip_info
      (0 .. (@sx - @ex).abs).each do |x|
        (0 .. (@sy - @ey).abs).each do |y|
          yield ChipData.generate(@chipset_no, ([@sy, @ey].min + y) * PALET_ROW_COUNT + ([@sx, @ex].min + x)), x, y
        end
      end
    end

    def active=(value)
      @active = value
      self.refresh
    end
    
    def active?
      return @active
    end
    
    def update_panel
      @texture.clear
      self.render_chips(@texture)
      @dst_texture = Texture.new(@texture.width * @zoom , @texture.height * @zoom)
      @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom)
    end
    
    def refresh
      self.update_panel
      paint{|dc|self.on_paint(dc)}
    end
    
    def on_size_changed(e)
      w = @texture.width
      h = @texture.height
      self.set_scrollbars(SRoga::Config::GRID_SIZE * @zoom - 16, SRoga::Config::GRID_SIZE * @zoom, w / (SRoga::Config::GRID_SIZE * @zoom), h / (SRoga::Config::GRID_SIZE * @zoom), 0, 0, true)
    end
    
    def on_paint(dc)
      do_prepare_dc(dc)
      dc.draw_texture(@dst_texture, 0, 0)
    end
    
    def on_left_down(e)
      tx1, ty1 = self.calc_scrolled_position(0, 0)
      tx2 = ((e.get_x - tx1) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
      ty2 = ((e.get_y - ty1) / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
      self.select(tx2, ty2)
    end
    
  	def on_motion(e)

  	end
    
    def select_chip_by_id(id)
      tx1 = (id % PALET_ROW_COUNT) * SRoga::Config::GRID_SIZE * 2
      ty1 = (id / PALET_ROW_COUNT) * SRoga::Config::GRID_SIZE * 2

      tx2 = (tx1 / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
      ty2 = (ty1 / (SRoga::Config::GRID_SIZE.to_f * @zoom)).floor
      self.select(tx2, ty2)
    end
    
    def select(x, y)
      @sx = x
      @sy = y
      @ex = @sx
      @ey = @sy
      
      self.refresh
    end
  end
end
