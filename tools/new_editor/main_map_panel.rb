require 'main_map_panel/map_panel'
require 'scroll_box'
require 'main_map_panel/tile_panel'

class MainMapPanel < Gtk::VBox
  def initialize
    super(false, 0)

    self.pack_start(create_toolbar, true, true, 0)

    tex = StarRuby::Texture.load("test.png")
    pixbuf = Gdk::Pixbuf.new(tex.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, tex.width, tex.height, tex.width * 3)

    h_box = Gtk::HBox.new
    tile_box = TilePanel.new
    tile_box.set_size_request(200, 200)

    h_box.add(tile_box)
    h_box.add(ScrollBox.new(MapPanel.new))

    t = Gtk::VBox.new(false, 10)
    t.add(h_box)
    self.pack_start(t, true, true, 0)
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
end