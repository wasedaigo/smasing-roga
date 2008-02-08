require 'gtk2'
require 'gnomecanvas2'
require 'starruby'
require 'main_map_panel'
window = Gtk::Window.new
window.title = "Hello Buttons"
window.border_width = 10
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

vbox = Gtk::VBox.new
vbox.add(create_menubar)
vbox.add(MainMapPanel.new)
window.add(vbox)

window.show_all
Gtk.main