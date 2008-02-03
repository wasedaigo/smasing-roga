$LOAD_PATH << "../../"

require "test/unit"
require "animation"
require "animation_loader"
class AnimationTest < Test::Unit::TestCase
  def test_update
    assert_raise(RuntimeError) do
      Graphics::Animation.new(0, [])
    end
    assert_raise(RuntimeError) do
      Graphics::Animation.new(1, [])
    end
  end
end
