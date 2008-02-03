module DRPGTool
  
  module View
    
    def controller
      @controller
    end
    
    def controller=(val)
      @controller.remove_view(self) if @controller
      @controller = val
      @controller.add_view(self) if @controller
    end
    
  end
  
end
