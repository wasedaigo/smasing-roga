module Transitionable

  #use it when you want to get the screen as a texture
  def get_texture still = false

    if @texture == nil
      @texture = Texture.new(Game.screen.width, Game.screen.height)
      self.render(@texture) if still
    end
    self.render(@texture) unless still
    return @texture
  end

end
