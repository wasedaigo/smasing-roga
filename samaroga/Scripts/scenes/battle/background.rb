class Background
  attr_accessor :src_x, :src_y

  BACKGROUND_WIDTH = 640
  BACKGROUND_HEIGHT = 480
  def initialize
    @texture = $res.get_texture("background")
  end

  def render(s, x, y)
    src_x = (BACKGROUND_WIDTH - SCREEN_WIDTH) / 2 - x
    src_y = (BACKGROUND_HEIGHT - SCREEN_HEIGHT) / 2 - y
    s.render_texture(@texture, 0, 0, :src_x => src_x, :src_y => src_y, :src_width =>SCREEN_WIDTH, :src_height =>SCREEN_HEIGHT)
  end
end
