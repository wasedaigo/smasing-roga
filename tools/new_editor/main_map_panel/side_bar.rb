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
        
        @map_navigator = Editor::Map::MapNavigator.new
        self.pack2(@map_navigator, false, true)
      end
      
      def palets
        return @palet_note_book.palets
      end
      
      def on_resize(width, height)
        @palet_note_book.on_resize(width, height - @map_navigator.height_request)
      end
    end
  end
end