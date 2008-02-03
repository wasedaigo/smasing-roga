module DRPGTool
  
  class TexturePanel < Wx::Panel
    
    attr_reader :texture
    
    def initialize(parent, id = Wx::ID_ANY)
      super(parent, id)
      @texture = StarRuby::Texture.load("town01_a")
      font = StarRuby::Font.new("Arial", 48)
      color = StarRuby::Color.new(255, 255, 255)
      @texture.render_text("Star Ruby rules!!", 8, 8, font, color, true)
      evt_paint do |e|
        paint do |dc|
          dc.draw_texture(@texture, 0, 0)
        end
      end
      evt_size do |e|
      end
    end
    
  end
  
end
