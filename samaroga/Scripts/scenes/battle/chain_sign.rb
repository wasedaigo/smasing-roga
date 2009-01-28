require  "dgo/graphics/sprite"
class ChainSign
  def initialize(base, x, y)
    @base = base
    @sprite = Sprite.new($res.get_texture("chain_sign"), x, y, :alpha => 155)
  end

  def update
  end
  
  def render(s, x = 0, y = 0)
    @sprite.render(s, x = 0, y = 0)
  end
end
