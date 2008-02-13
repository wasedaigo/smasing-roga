require 'scenes/map/map'
require 'scenes/map/map_layer'
require 'scenes/map/map_chipset'
require 'scenes/map/auto_map_chipset'
require 'scenes/map/map_loader'

module Editor
  module Map
    class Mappanel  < Gtk::ScrolledWindow
      TestMapChipset = SRoga::AutoMapChipset.new("ChipSet2", 16)
      TestMapChipset2 = SRoga::MapChipset.new("ChipSet", 16)

      def initialize
        super
        self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
        data = SRoga::MapLoader.loadMap
        @tile_w_count = data[:wCount]
        @tile_h_count = data[:hCount]
        @map_width = @tile_w_count * SRoga::Config::GRID_SIZE
        @map_height = @tile_h_count * SRoga::Config::GRID_SIZE
        @map = SRoga::Map.new(@tile_w_count, @tile_h_count, @tile_w_count, @tile_h_count, data[:collisionData], 0  => TestMapChipset, 1  => TestMapChipset2)
        @layers = [SRoga::MapLayer.new(@map, data[:bottomLayer]), SRoga::MapLayer.new(@map, data[:topLayer])]

        @texture = StarRuby::Texture.new(@map.width, @map.height)
        @zoom = 1
        @image = Gtk::Image.new
        @image.set_alignment(0, 0)

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

        @dst_texture = Texture.new(tw, th)
        @dst_texture.render_texture(@texture, 0, 0, :scale_x => @zoom, :scale_y => @zoom, :src_x => ttx, :src_y => tty, :src_width => [tw, @texture.width - ttx].min, :src_height => [th, @texture.height - tty].min)
      end

      def render
        update_panel
        @image.pixbuf = Gdk::Pixbuf.new(@dst_texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @dst_texture.width, @dst_texture.height, @dst_texture.width * 3)

        #はまった・・・
        t = Gtk::EventBox.new
        t.add_events(Gdk::Event::POINTER_MOTION_MASK)
        t.signal_connect("event") do |item, event|
        t.can_focus = true
        t.has_focus = true
          p event.event_type
        end
        t.add(@image)
        self.add_with_viewport(t)
      end
    end
  end
end