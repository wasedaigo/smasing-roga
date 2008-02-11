$LOAD_PATH << "../../Scripts/"
$data_path = "../../"
require 'starruby'
require 'resource_manager'
$res = ResourceManager.new("Data/anime_file.csv")

require 'gtk2'
require 'gnomecanvas2'
require 'main_map_panel/main_container'

window = Gtk::Window.new
window.title = "Hello Buttons"
window.signal_connect("delete_event") do
	Gtk::main_quit
	false
end

def create_menubar
  menubar = Gtk::MenuBar.new

  menuitem = Gtk::MenuItem.new("File")
  menubar.append(menuitem)
  menuitem.show

  menuitem = Gtk::MenuItem.new('Config')
  menubar.append(menuitem)
  menuitem.show
  
  return menubar
end

def create_toolbar
  toolbar = Gtk::Toolbar.new
  toolbar.append("Horizontal", "Horizontal toolbar layout",
     "Toolbar/Horizontal", Gtk::Image.new("test.xpm")){
    toolbar.orientation = Gtk::ORIENTATION_HORIZONTAL
  }
  toolbar.append("Vertical", "Vertical toolbar layout",
     "Toolbar/Vertical", Gtk::Image.new("test.xpm")){
    toolbar.orientation = Gtk::ORIENTATION_VERTICAL
  }
  toolbar.append_space
  return toolbar
end

# t = Gtk::VBox.new
# t.add(create_menubar)
# t.add(create_toolbar)
# t.add(Editor::Map::MainContainer.new)
# t.add(Gtk::Statusbar.new)

vbox = Gtk::VBox.new
table = Gtk::Table.new(1, 4)
table.attach(create_menubar, 0, 1, 0, 1, Gtk::EXPAND | Gtk::FILL, 0)
table.attach(create_toolbar, 0, 1, 1, 2, Gtk::EXPAND | Gtk::FILL, 0)
table.attach(Editor::Map::MainContainer.new, 0, 1, 2, 3, Gtk::EXPAND | Gtk::FILL, Gtk::EXPAND | Gtk::FILL)
table.attach(Gtk::Statusbar.new, 0, 1, 3, 4, Gtk::EXPAND | Gtk::FILL, 0)

window.add(table)
window.allow_shrink=true
window.show_all
Gtk.main