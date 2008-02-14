require 'main_map_panel/palet_panel'
require 'main_map_panel/normal_palet_panel'
module Editor
  module Map
    class PaletNotebook < Gtk::Notebook
      def initialize
        super
        self.set_tab_pos(Gtk::POS_BOTTOM)
        
        @palet = NormalPaletPanel.new(480)
        self.append_page(@palet, Gtk::Label.new("Normal Tile"))
        
      end
      
      def palets
        return [@palet]
      end
    end
  end
end