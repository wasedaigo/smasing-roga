$LOAD_PATH << "../../Scripts/"
$data_path = "../../"

# Star Ruby
require 'starruby'
require 'resource_manager'
$res = ResourceManager.new("Data/anime_file.csv")

# Gnome2
require 'gtk2'
require 'gnomecanvas2'
require 'main_map_panel/main_container'

def set_background_image(path, target)
  tex = StarRuby::Texture.load(path)
  pixbuf = Gdk::Pixbuf.new(tex.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, tex.width, tex.height, tex.width * 3)
  pixmap, mask = pixbuf.render_pixmap_and_mask(0)
  #target.style.set_bg_pixmap(Gtk::STATE_NORMAL, pixmap)

  style = target.style
  style.set_bg_pixmap(Gtk::STATE_NORMAL, pixmap)
  #style.set_fg_pixmap(Gtk::STATE_NORMAL, pixmap)

  style.set_bg_pixmap(Gtk::STATE_ACTIVE, pixmap)
  #style.set_fg_pixmap(Gtk::STATE_ACTIVE, pixmap)
  
  style.set_bg_pixmap(Gtk::STATE_PRELIGHT, pixmap)
  #style.set_fg_pixmap(Gtk::STATE_PRELIGHT, pixmap)

  style.set_bg_pixmap(Gtk::STATE_INSENSITIVE, pixmap)
  #style.set_fg_pixmap(Gtk::STATE_INSENSITIVE, pixmap)
 
  style.set_bg_pixmap(Gtk::STATE_SELECTED, pixmap)
  #style.set_fg_pixmap(Gtk::STATE_SELECTED, pixmap)
  
  target.style = style

end

class Main

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
  
  def initialize  
    window = Gtk::Window.new
    $window = window
    
    # geometry = Gdk::Geometry.new
    # geometry.set_min_width(480)
    # geometry.set_min_height(480)
    # geometry.set_width_inc(1)
    # geometry.set_height_inc(1)

# mask = Gdk::Window::HINT_MIN_SIZE | Gdk::Window::HINT_RESIZE_INC

    # window.set_geometry_hints(window, geometry, mask)

    window.title = "Hello Buttons"
    window.signal_connect("delete_event") do
    	Gtk::main_quit
    	false
    end

    
    vbox = Gtk::VBox.new
    table = Gtk::Table.new(1, 4)  
    
    menubar = create_menubar
    table.attach(menubar, 0, 1, 0, 1, Gtk::EXPAND | Gtk::FILL, 0)
    
    toolbar = create_toolbar
    table.attach(toolbar, 0, 1, 1, 2, Gtk::EXPAND | Gtk::FILL, 0)
    
    main_container = Editor::Map::MainContainer.new
    table.attach(main_container, 0, 1, 2, 3, Gtk::EXPAND | Gtk::FILL, Gtk::EXPAND | Gtk::FILL)

    statusbar = Gtk::Statusbar.new
    table.attach(statusbar, 0, 1, 3, 4, Gtk::EXPAND | Gtk::FILL, 0)

    window.add(table)
    window.allow_shrink=true
    window.set_width_request(792)
    window.set_height_request(600)

    window.show_all

    window.signal_connect("configure_event") do |item, event|
    	main_container.on_resize(event.width, event.height - 86)
    end
    
    Gtk.main
  end
end

Main.new