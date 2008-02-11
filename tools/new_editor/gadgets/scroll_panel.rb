module Editor
  class ScrollBox < Gtk::HBox
    def initialize
      
      v_box1 = Gtk::VBox.new
      v_box2 = Gtk::VBox.new
      Gtk::HScrollbar.new
      Gtk::VScrollbar.new
    end
  end
end