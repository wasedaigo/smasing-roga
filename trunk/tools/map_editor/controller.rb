module DRPGTool
  
  class Controller
    
    def initialize(model)
      @model = model
      @model.add_controller(self)
      @views = []
    end
    
    def [](model_id, key)
      @model[model_id, key]
    end
    
    def []=(model_id, key, value)
      @model[model_id, key] = value
    end
    
    def add_item
      @model.add_item
    end
    
    def add_view(view)
      unless @views.include?(view)
        @views << view
        view.on_init
      end
    end
    
    def remove_view(view)
      @views.delete(view)
    end
    
    def on_updated(e)
      @views.each do |view|
        view.on_updated(e)
      end
    end
    
    def each_model_id
      @model.each_id do |model_id|
        yield(model_id)
      end
    end
    
  end
  
end
