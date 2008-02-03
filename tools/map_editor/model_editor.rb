require "wx"
require "view"

module DRPGTool
  
  class ModelEditor < Wx::Panel
    
    def initialize(parent, controller)
      super(parent)
      
      splitter = Wx::SplitterWindow.new(self)
      
      list_panel = Wx::Panel.new(splitter)
      
      style = Wx::LC_REPORT | Wx::LC_HRULES | Wx::LC_VRULES | Wx::LC_SORT_ASCENDING
      list = Wx::ListCtrl.new(list_panel, :style => style)
      (class << list; self; end).class_eval %Q{
        include View
        
        def add_model_item(model_id)
          index = insert_item(0, controller[model_id, :name])
          (class << get_item(index); self; end).class_eval %Q{
            include View
            def on_updated(e)
            end
          }
        end
        
        private :add_model_item
        
        def on_init
          controller.each_model_id do |model_id|
            add_model_item(model_id)
          end
          refresh
        end
        
        def on_updated(e)
          case e.type
          when :add_item
            add_model_item(e.model_id)
          end
          refresh
        end
      }
      list.controller = controller
      list.insert_column(0, "Name")
      list.set_column_width(0, 160)
      
      add_button = Wx::Button.new(list_panel, -1, :label => "Add")
      evt_button(add_button.get_id) do |e|
        controller.add_item
      end
      
      button_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      button_sizer.add(add_button, 0)
      
      list_panel.sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      list_panel.sizer.add(list, 1, Wx::EXPAND)
      list_panel.sizer.add(button_sizer, 0, Wx::BOTTOM)
      
      sme = Wx::Panel.new(splitter)
      splitter.split_vertically(list_panel, sme, 200)
      splitter.minimum_pane_size = 10
      
      self.sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      # self.sizer.add(button_sizer, 0, Wx::BOTTOM)
      self.sizer.add(splitter, 1, Wx::EXPAND)
    end
    
  end
  
end
