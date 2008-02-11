module Editor
  module Map
    class TilePanel < Gtk::ScrolledWindow
      def initialize(h)
        super()
        self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
        @texture = StarRuby::Texture.load("test.png")
        pixbuf = Gdk::Pixbuf.new(@texture.dump('rgb'), Gdk::Pixbuf::ColorSpace.new(Gdk::Pixbuf::ColorSpace::RGB), false, 8, @texture.width, @texture.height, @texture.width * 3)

        t = Gtk::Image.new(pixbuf)
        t.set_alignment(0, 0)
        self.add_with_viewport(t)
        self.set_height_request(h)
      end
    end
  end
end