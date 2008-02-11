class TilePanel < Gtk::ScrolledWindow
  def initialize
    super
    @texture = StarRuby::Texture.load("test.png")
    pixbuf = Gdk::Pixbuf.new(@texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @texture.width, @texture.height, @texture.width * 3)

    container = Gtk::Viewport.new(Gtk::Adjustment.new(300, 300, 300, 1, 16, 100), Gtk::Adjustment.new(300, 300, 300, 1, 16, 100))
    container.add(Gtk::Image.new(pixbuf))
    self.add(container)
  end
end