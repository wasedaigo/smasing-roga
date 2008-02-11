module Editor
  module Map
    class MapNavigator < Gtk::ScrolledWindow
      def initialize
        super
        self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
        t = Gtk::TreeView.new
        t.set_height_request(200)
        self.add(t)
      end
    end
  end
end