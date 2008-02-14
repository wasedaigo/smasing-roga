require 'main_map_panel/map_panel'
require 'main_map_panel/palet_notebook'
require 'main_map_panel/map_navigator'
module Editor
  module Map
    class Sidebar < Gtk::VPaned
      def initialize
        super
        @palet_note_book = Editor::Map::PaletNotebook.new
        self.pack1(@palet_note_book, true, true)
        self.pack2(Editor::Map::MapNavigator.new, false, true)
      end
      
      def palets
        return @palet_note_book.palets
      end
    end
  end
end