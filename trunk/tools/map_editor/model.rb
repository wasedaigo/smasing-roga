module DRPGTool
  
  UpdatedEventArgs = Struct.new(:type, :model_id)
  
  class Model
    
    def initialize(store)
      @store = store
      @controllers = []
    end
    
    def [](model_id, key)
      @store.transaction do
        @store[model_id][key]
      end
    end
    
    def []=(model_id, key, value)
      @store.transaction do
        @store[model_id][key] = value
      end
      e = UpdatedEventArgs.new
      e.type = :updated_attr
      on_updated(e)
    end
    
    def add_item
      e = UpdatedEventArgs.new
      @store.transaction do
        e.type = :add_item
        e.model_id = (@store.roots.max || 0) + 1
        @store[e.model_id] = {:name => ""}
      end
      on_updated(e)
    end
    
    def add_controller(controller)
      @controllers << controller unless @controllers.include?(controller)
    end
    
    def remove_controller(controller)
      @controllers.delete(controller)
    end
    
    def on_updated(e)
      @controllers.each do |controller|
        controller.on_updated(e)
      end
    end
    
    def each_id
      @store.transaction{@store.roots}.each do |id|
        yield(id)
      end
    end
    
  end
  
end
