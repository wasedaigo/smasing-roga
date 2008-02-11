require 'main_map_panel/side_bar'
require 'main_map_panel/map_panel'
module Editor
  module Map
    class MainContainer < Gtk::HBox
      def initialize
        super
        
        t = Gtk::Table.new(2, 1)
        t2 = Editor::Map::Sidebar.new
        t2.set_width_request(320)
        t2.set_height_request(1)
        t.attach(t2, 0, 1, 0, 1, 0, Gtk::EXPAND | Gtk::FILL, 0)
        t.attach(Editor::Map::Mappanel.new, 1, 2, 0, 1, Gtk::EXPAND | Gtk::FILL, Gtk::EXPAND | Gtk::FILL)
        
        self.add(t)
      end
    end
  end
end