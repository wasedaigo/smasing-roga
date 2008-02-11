require 'scenes/map/map'
require 'scenes/map/map_layer'
require 'scenes/map/map_chipset'
require 'scenes/map/auto_map_chipset'
require 'scenes/map/map_loader'

class MapPanel < Gtk::HBox
  TestMapChipset = AutoMapChipset.new("ChipSet2", 16)
  TestMapChipset2 = MapChipset.new("ChipSet", 16)

  def initialize
    super(false, 0)
    data = MapLoader.loadMap
    @tile_w_count = data[:wCount]
    @tile_h_count = data[:hCount]
    @map_width = @tile_w_count * Config::GRID_SIZE
    @map_height = @tile_h_count * Config::GRID_SIZE
    @map =  Map.new(@tile_w_count, @tile_h_count, @tile_w_count, @tile_h_count, data[:collisionData], 0  => TestMapChipset, 1  => TestMapChipset2)
    @layers = [MapLayer.new(@map, data[:bottomLayer]), MapLayer.new(@map, data[:topLayer])]

    @texture = Texture.new(@map_width, @map_height)
    @zoom = 1

    self.render
  end
  
  def update_panel
    @map.base_x = 0
    @map.base_y = 0
    @map.update(@map_width, @map_height, [@layers[0]])
    @texture.clear
    @layers.each{|layer|@map.render(@texture, layer)}

    tx = 0
    ty = 0
    tw = @map_width * @zoom
    th = @map_height * @zoom
    ttx = -tx / @zoom
    tty = -ty / @zoom
    #self.render_frame(@texture)
    @dst_texture = Texture.new(tw, th)
    @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom, :src_x => ttx, :src_y => tty, :src_width => [tw, @texture.width - ttx].min, :src_height => [th, @texture.height - tty].min)
  end
  
  def render
    update_panel
    pixbuf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @texture.width, @texture.height, @texture.width * 3)
    self.add(Gtk::Image.new(pixbuf))
  end
end