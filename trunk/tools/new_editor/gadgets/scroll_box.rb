module Editor
  class ScrollBox < Gtk::HBox
    attr_reader :client_width, :client_height ,:h_scrollbar, :v_scrollbar
    attr_accessor :grid_size
    
#initialize
    def initialize(client_width, client_height, grid_size, &resize_event)
      super(false, 0)
      @resize_event = resize_event
      @grid_size = grid_size.to_f
      
      @content_image = Gtk::DrawingArea.new
      @content_image.set_size_request(1,1)
      @content_image.add_events(Gdk::Event::POINTER_MOTION_MASK)
      @content_image.add_events(Gdk::Event::BUTTON_PRESS_MASK)
      @content_image.add_events(Gdk::Event::BUTTON_RELEASE_MASK)
        
      @scroll_valid = false
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

      @content_image.signal_connect("expose_event") do
        self.on_resize
      end

      @h_scrollbar.adjustment.signal_connect("value-changed") do |item, event|
        @resize_event.call("render") if @scroll_valid
      end

      @v_scrollbar.adjustment.signal_connect("value-changed") do |item, event|
        @resize_event.call("render") if @scroll_valid
      end
      
      self.set_client_size(client_width, client_height)
      self.set_size(1, 1)
      @scroll_valid = true
    end
    
# Property
    def content_image
      return @content_image
    end
 
    def w_grid_count
      return (@content_image.allocation.width / self.grid_size).floor
    end
    
    def h_grid_count
      return (@content_image.allocation.height / self.grid_size).floor
    end
    
    def width
      return @content_image.width_request
    end

    def height
      return @content_image.height_request
    end
 
    def content_width
      return @content_image.allocation.width
    end

    def content_height
      return @content_image.allocation.height
    end
    
    def grid_size=(value)
      return if @grid_size == value
      @grid_size = value
    end
# methods
    def set_client_size(width, height)
      @client_width = width
      @client_height = height
      #@content_image.set_size_request(self.width_request, self.height_request)
    end
    
    def set_size(width, height)
      @content_image.set_size_request((width / self.grid_size).floor * self.grid_size, (height / self.grid_size).floor * self.grid_size)
    end
    
    def refresh_scrollbars
      @scroll_valid = false
      self.refresh_hscrollbar
      self.refresh_vscrollbar
      @scroll_valid = true
    end
    
    def refresh_hscrollbar
    #p "w1:#{@content_image.allocation.width} width:#{self.content_width} client_width:#{@client_width} ajv#{@h_scrollbar.adjustment.value}"
      if @client_width > self.content_width
        @h_scrollbar.adjustment.upper = (@client_width / self.grid_size).floor
        @h_scrollbar.adjustment.step_increment = 1
        @h_scrollbar.adjustment.page_increment = 6
        @h_scrollbar.adjustment.page_size = (self.content_width / self.grid_size).floor
      else
        @h_scrollbar.adjustment.page_size = (self.content_width / self.grid_size).floor
      end
      
      @h_scrollbar.adjustment.value = [@h_scrollbar.adjustment.upper - @h_scrollbar.adjustment.page_size, @h_scrollbar.adjustment.value].min
      @h_scrollbar.queue_draw
    end
 
    def refresh_vscrollbar
      
      if @client_height > self.content_height
        @v_scrollbar.adjustment.upper = (@client_height / self.grid_size).floor
        @v_scrollbar.adjustment.step_increment = 1
        @v_scrollbar.adjustment.page_increment = 6
        @v_scrollbar.adjustment.page_size = (self.content_height / self.grid_size).floor
      else
        @v_scrollbar.adjustment.page_size = (self.content_height / self.grid_size).floor
      end
      
      @v_scrollbar.adjustment.value = [@v_scrollbar.adjustment.upper - @v_scrollbar.adjustment.page_size, @v_scrollbar.adjustment.value].min
      @v_scrollbar.queue_draw
      #p "height:#{self.content_height} client_height:#{@client_height} ajv#{@v_scrollbar.adjustment.value} upper#{@v_scrollbar.adjustment.upper} gs#{@v_scrollbar.adjustment.page_size}"
    end

#events
    def on_resize
      width = [@client_width, self.content_width].min
      height = [@client_height, self.content_height].min

      set_size_request(width, height)
      self.set_size(width, height)
      
      self.refresh_scrollbars
      @resize_event.call("resize")
    end
  end
end