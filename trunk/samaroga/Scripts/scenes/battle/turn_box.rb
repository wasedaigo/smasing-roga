class TurnBox
  attr_reader :unit
  attr_accessor :offset, :index
  
  def initialize(unit, index)
    @unit = unit
    @offset = 0
    @index = index
  end

  def texture
    if @texture.nil?
      @texture = Texture.new(20, 19)
      @texture.render_texture($res.get_texture("face_box"), 0, 0, :src_width => 20)
      @texture.render_texture(@unit.icon_texture, 2, 0)
      @texture.render_texture($res.get_texture("face_box"), 0, 0, :src_x => 20, :src_width => 20)
    end
    return @texture
  end

  def render(s, x, y)
    s.render_texture(self.texture, x + @offset, y)
  end
end