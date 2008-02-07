require 'gtk2'
require 'gnomecanvas2'
require 'starruby'

window = Gtk::Window.new
window.title = "Hello Buttons"
window.border_width = 10

tex =StarRuby::Texture.load("background.png")
pixbuf = Gdk::Pixbuf.new(tex.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, tex.width, tex.height, tex.width * 3)
window.add(Gtk::Image.new(pixbuf))

window.show_all
Gtk.main