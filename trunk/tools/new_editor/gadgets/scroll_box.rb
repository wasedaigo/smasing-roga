module Editor
  class ScrollBox < Gtk::HBox
    def initialize(box)
      super(false, 0)
      v_box1 = Gtk::VBox.new
      v_box2 = Gtk::VBox.new
   

      v_box1.add(box)
      v_box1.add(Gtk::HScrollbar.new)
      
      box.width_request = 200
      box.height_request = 200
      
      v_scrollbar = Gtk::VScrollbar.new
      v_scrollbar.height_request = box.height_request
      v_box2.add(v_scrollbar)
      self.add(v_box1)
      self.add(v_box2)
    end

  end
end