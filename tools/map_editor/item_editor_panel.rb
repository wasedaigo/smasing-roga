require "wx"

module DRPGTools
  
  class ItemEditorPanel < Wx::Panel
    
    attr_reader :data
    
    def initialize(parent, data)
      super(parent, -1)
      @data = data
      
      id = Wx::ID_HIGHEST
      l1 = Wx::StaticText.new(self, -1, "Name:")
      t1 = Wx::TextCtrl.new(self, (id += 1))
      t1.value = data[:name] if data.include?(:name)
      evt_text(t1.get_id) do |e|
        @data[:name] = e.string
      end
      
      l2 = Wx::StaticText.new(self, -1, "Cost:")
      t2 = Wx::TextCtrl.new(self, (id += 1))
      t2.value = data[:cost] if data.include?(:cost)
      evt_text(t2.get_id) do |e|
        @data[:cost] = e.string
      end
      
      sizer = Wx::FlexGridSizer.new(0, 1, 5, 5)
      sizer.add(l1)
      sizer.add(t1)
      sizer.add(0, 5)
      sizer.add(l2)
      sizer.add(t2)
      
      self.sizer = sizer
      self.auto_layout = true
    end
    
  end
  
end
