require 'main_map_panel/map_panel'
require 'main_map_panel/tile_notebook'
require 'main_map_panel/map_navigator'
module Editor
  module Map
    class Sidebar < Gtk::VPaned
      def initialize
        super
        self.pack1(Editor::Map::TileNotebook.new, true, true)
        self.pack2(Editor::Map::MapNavigator.new, false, true)
      end
    end
  end
end