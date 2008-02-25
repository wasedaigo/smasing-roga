require 'main_map_panel/palet_panel'
require 'main_map_panel/normal_palet_panel'
module Editor
  module Map
    class PaletNotebook < Gtk::Notebook
      def initialize
        super
        self.set_tab_pos(Gtk::POS_BOTTOM)
        
        @palet1 = NormalPaletPanel.new(480)
        self.append_page(@palet1, Gtk::Label.new("Normal Tile"))
        
        @palet2 = NormalPaletPanel.new(480)
        self.append_page(@palet2, Gtk::Label.new("Normal Tile2"))
      end
      
      def palets
        return [@palet1, @palet2]
      end
    end
  end
end