module DRPGTool

  class MapEditorFrame < Wx::Frame

    def initialize
      super(nil, :title => "DRPGTools", :size => [800, 600])

      main_menu = Wx::MenuBar.new
      
      menu = Wx::Menu.new
      menu.append(Wx::ID_EXIT, "E&xit")
      evt_menu(Wx::ID_EXIT) {exit}
      main_menu.append(menu, "&File")
      
      menu = Wx::Menu.new
      menu.append(Wx::ID_HIGHEST + 1, "&Run")
      evt_menu(Wx::ID_HIGHEST + 1) do
        begin
          disable
          StarRuby::Game.run(320, 240) do
          end
        ensure
          enable
          set_focus
        end
      end
      main_menu.append(menu, "&Game")

      menu = Wx::Menu.new
      menu.append(Wx::ID_ABOUT, "&About")
      main_menu.append(menu, "&Help")
      self.menu_bar = main_menu
      
      status_bar = Wx::StatusBar.new(self)
      self.status_bar = status_bar
      
      main_splitter_class = Class.new(Wx::SplitterWindow)
      main_splitter_class.class_eval %Q{
        def initialize(parent)
          super(parent, object_id)
          evt_splitter_sash_pos_changed(object_id) do |e|
            e.sash_position = self.sash_position = 200
          end
          evt_splitter_sash_pos_changing(object_id) do |e|
            e.sash_position = self.sash_position = 200
          end
        end
      }
      splitter = main_splitter_class.new(self)
      
      splitter2 = Wx::SplitterWindow.new(splitter)
      panel = Wx::TextCtrl.new(splitter2)
      tree = Wx::TextCtrl.new(splitter2)
      splitter2.split_horizontally(panel, tree, 500)
      splitter2.minimum_pane_size = 20
      
      splitter.split_vertically(splitter2, TexturePanel.new(splitter, 1000), 200)
      splitter.minimum_pane_size = 20
    end
  end
  
end
