module Editor
  class ScrollBox < Gtk::HBox
    attr_reader :client_width, :client_height ,:h_scrollbar, :v_scrollbar
    
#initialize
    def initialize(client_width, client_height, width, height)
      super(false, 0)
      @content_image = Gtk::DrawingArea.new
      @content_image.set_size_request(600,600)
@content_image.add_events(Gdk::Event::POINTER_MOTION_MASK)
@content_image.add_events(Gdk::Event::BUTTON_PRESS_MASK)
@content_image.add_events(Gdk::Event::BUTTON_RELEASE_MASK)
       @image_box = Gtk::EventBox.new
      # @image_box.add_events(Gdk::Event::POINTER_MOTION_MASK)
      # @image_box.add_events(Gdk::Event::CONFIGURE)
      # @image_box.add(@content_image)
      # @image_box.set_size_request(width, height)
      #@content_image.set_alignment(0, 0)
      
      
      #vp = Gtk::Viewport.new(Gtk::Adjustment.new(0, 0, 200, 1, 1, 1), Gtk::Adjustment.new(0, 0, 200, 1, 1, 1))
      #vp.add(@image_box)
      #vp.set_size_request(200, 200)
      @h_scrollbar = Gtk::HScrollbar.new
      @v_scrollbar = Gtk::VScrollbar.new
      vbox1 = Gtk::VBox.new

      vbox1.pack_start(@content_image, true, true, 0)
      vbox1.pack_start(@h_scrollbar, false, false, 0)
      
      hbox1 = Gtk::HBox.new
      hbox1.add(vbox1)
      @hbox1 = hbox1
      vbox2 = Gtk::VBox.new
      vbox2.pack_start(@v_scrollbar, true, true, 0)
      
      t = Gtk::EventBox.new
      t.set_size_request(16, 16)
      vbox2.pack_start(t, false, false, 0)
      
      hbox1.pack_start(vbox2, false, false, 0)

      
      set_background_image("Data/Icon/tex.png", @content_image)
      self.pack_start(hbox1, true, true, 0)

      @client_width = client_width
      @client_height = client_height
      self.set_client_size(client_width, client_height)
      self.set_size(width, height)
      
      set_signals
    end
    
    def set_signals    
      @image_box.signal_connect("event") do |item, event|
        case(event.event_type)
          when(Gdk::Event::BUTTON_PRESS)
            self.signal_emit("button_press_event", event)
          when(Gdk::Event::MOTION_NOTIFY)
            self.signal_emit("motion_notify_event", event)
          when(Gdk::Event::BUTTON_RELEASE)
            self.signal_emit("button_release_event", event)

        end
      end
    end
    
# Property
    def content_image
      return @content_image
    end
    
    def width
      return content_image.width_request
    end

    def height
      return content_image.height_request
    end
    
# methods
    def set_client_size(width, height)
      @client_width = width
      @client_height = height
      @content_image.set_size_request(self.width_request, self.height_request)
      self.refresh_scrollbars
    end
    
    def set_size(width, height)
      @content_image.set_size_request(width, height)
      @image_box.set_size_request(@content_image.width_request, @content_image.height_request)
      self.refresh_scrollbars
    end
    
    def refresh_scrollbars
      self.refresh_hscrollbar
      self.refresh_vscrollbar
    end
    
    def refresh_hscrollbar
      if @client_width > self.width
        t = @client_width - self.width

        if @h_scrollbar.adjustment.nil?
          @h_scrollbar.adjustment = Gtk::Adjustment.new(@h_scrollbar.adjustment.value, 0, t, SRoga::Config::GRID_SIZE, SRoga::Config::GRID_SIZE * 6, (t * (self.width / @client_width.to_f)).floor)
        else
          @h_scrollbar.adjustment.value = [@h_scrollbar.adjustment.value ,t].min
          @h_scrollbar.adjustment.upper = t
          @h_scrollbar.adjustment.step_increment = SRoga::Config::GRID_SIZE
          @h_scrollbar.adjustment.page_increment = SRoga::Config::GRID_SIZE * 6
          @h_scrollbar.adjustment.page_size = (t * (self.width / @client_width.to_f)).floor
        end
      end
    end
 
    def refresh_vscrollbar
      if @client_height > self.height
        t = @client_height - self.height
        @v_scrollbar.adjustment = Gtk::Adjustment.new(@v_scrollbar.adjustment.value, 0, t, SRoga::Config::GRID_SIZE, SRoga::Config::GRID_SIZE * 6, (t * (self.width / @client_height.to_f)).floor)
      end
    end

#events
    def on_resize(area_width, area_height, width, height)
      p "RESIZE #{width} * #{height}"
      self.set_size_request(width, height)
      self.set_size(area_width, area_height)
    end
  end
end