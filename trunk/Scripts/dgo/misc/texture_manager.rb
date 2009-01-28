include StarRuby
module DGO::Misc
  class TextureManager
    def initialize(root = ".")
      @root = root
      @textures = {}
    end
    
    def clear_texture_cache
      @textures.clear
    end
    
    def get_texture(id, cache = true)
      if @textures[id].nil?
        @textures[id] = Texture.load("#{@root}/#{id}")
      end
      return @textures[id]
    end
  end
end
