require 'gtk2'
require 'gnomecanvas2'
require 'starruby'

window = Gtk::Window.new
window.title = "Hello Buttons"
window.border_width = 10
window.signal_connect("delete_event") do
	Gtk::main_quit
	false
end

  def create_menu (depth, tearoff)
    if depth < 1
  return nil
    end

    menu = Gtk::Menu.new
    group = nil

    if tearoff
  menuitem = Gtk::TearoffMenuItem.new
  menu.append(menuitem)
  menuitem.show
    end

    5.times do |i|
  buf = sprintf('item %2d - %d', depth, i + 1)
  menuitem = Gtk::RadioMenuItem.new(buf)
  group = menuitem.group

  menu.append(menuitem)
  menuitem.show
  if i == 3
  menuitem.sensitive = false
  end

  if submenu = create_menu(depth - 1, true)
  menuitem.submenu = submenu
  end
    end

    menu.show
    return menu
  end

tex =StarRuby::Texture.load("background.png")
pixbuf = Gdk::Pixbuf.new(tex.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, tex.width, tex.height, tex.width * 3)


h_box = Gtk::HBox.new(false, 0)
h_box.add(Gtk::Image.new(pixbuf))

menubar = Gtk::MenuBar.new
menu = create_menu(2, true)

menuitem = Gtk::MenuItem.new("test\nline2")
menuitem.submenu = menu
menubar.append(menuitem)
menuitem.show

menuitem = Gtk::MenuItem.new('foo')
menuitem.submenu = create_menu(3, true)
menubar.append(menuitem)
menuitem.show

menuitem = Gtk::MenuItem.new('bar')
menuitem.submenu = create_menu(4, true)
menuitem.right_justified = true
menubar.append(menuitem)
menuitem.show

window.add(menubar)
window.add(h_box)

window.show_all
Gtk.main