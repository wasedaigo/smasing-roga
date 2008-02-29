module Editor
  class ScrollBox < Gtk::HBox
    attr_reader :client_width, :client_height ,:h_scrollbar, :v_scrollbar
    attr_accessor :grid_size
    
#initialize
    def initialize(client_width, client_height, width, height, grid_size)
      super(false, 0)
      
      self.grid_size = grid_size
      
      @content_image = Gtk::DrawingArea.new
      @content_image.set_size_request(600,600)
      @content_image.add_events(Gdk::Event::POINTER_MOTION_MASK)
      @content_image.add_events(Gdk::Event::BUTTON_PRESS_MASK)
      @content_image.add_events(Gdk::Event::BUTTON_RELEASE_MASK)

      @h_scrollbar = Gtk::HScrollbar.new
      @v_scrollbar = Gtk::VScrollbar.new
      vbox1 = Gtk::VBox.new

      vbox1.pack_start(@content_image, true, true, 0)
      vbox1.pack_start(@h_scrollbar, false, false, 0)
      @vbox1 = vbox1
      
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
      self.refresh_scrollbars
    end
    
    def refresh_scrollbars
      self.refresh_hscrollbar
      self.refresh_vscrollbar
    end
    
    def refresh_hscrollbar
    p "w1:#{@content_image.allocation.width} width:#{self.width} client_width:#{self.client_width} ajv#{@h_scrollbar.adjustment.value}"
      @h_scrollbar.adjustment.value = [client_width - self.width, @h_scrollbar.adjustment.value].min
      if @client_width > self.width
        
        @h_scrollbar.adjustment.upper = client_width
        @h_scrollbar.adjustment.step_increment = self.grid_size
        @h_scrollbar.adjustment.page_increment = self.grid_size * 6
        @h_scrollbar.adjustment.page_size = self.width
      else
        @h_scrollbar.adjustment.page_size = self.width
      end
    end
 
    def refresh_vscrollbar
    
      @v_scrollbar.adjustment.value = [client_height - self.height, @v_scrollbar.adjustment.value].min
      if @client_height > self.height
        
        @v_scrollbar.adjustment.upper = client_height
        @v_scrollbar.adjustment.step_increment = self.grid_size
        @v_scrollbar.adjustment.page_increment = self.grid_size * 6
        @v_scrollbar.adjustment.page_size = self.height
      else
        @v_scrollbar.adjustment.value = [@v_scrollbar.adjustment.value ,self.height].min
      end
    end

#events
    def on_resize(area_width, area_height, width, height)
      p "RESIZE #{width} * #{height}"
      self.set_size_request((width / self.grid_size).round * self.grid_size, height)
      self.set_size(area_width, area_height)
    end
  end
end