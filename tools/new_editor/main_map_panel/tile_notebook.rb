require 'main_map_panel/tile_panel'
module Editor
  module Map
    class TileNotebook < Gtk::Notebook
      def initialize
        super
        self.set_tab_pos(Gtk::POS_BOTTOM)
        self.append_page(TilePanel.new(480), Gtk::Label.new("Normal Tile"))
        
      end
    end
  end
end