require 'main_map_panel/side_bar'
require 'main_map_panel/map_panel'
module Editor
  module Map
    class MainContainer < Gtk::HBox
      attr_reader :map_panel
      def initialize
        super
        
        t = Gtk::Table.new(2, 1)
        @side_bar = Editor::Map::Sidebar.new
        @side_bar.set_width_request(296)
        @side_bar.set_height_request(1)
        t.attach(@side_bar, 0, 1, 0, 1, 0, Gtk::EXPAND | Gtk::FILL, 0)

        @side_bar.palets.each do |palet|
          palet.load_chipset
          palet.render
        end

        @map_panel = Editor::Map::MapPanel.new(@side_bar.palets)
        t.attach(@map_panel, 1, 2, 0, 1, Gtk::EXPAND | Gtk::FILL, Gtk::EXPAND | Gtk::FILL)
        
        self.add(t)
      end
      
      def on_resize(width, height)
        @map_panel.on_resize(width - @side_bar.width_request, height)
        @side_bar.on_resize(@side_bar.width_request, height)
      end
    end
  end
end