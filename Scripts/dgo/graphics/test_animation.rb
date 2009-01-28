require "test/unit"
require "dgo/graphics/animation"
require "dgo/graphics/animation_loader"
require "dgo/graphics/target_object"

class AnimationTest < Test::Unit::TestCase

  include DGO::Graphics

  def test_update
    assert_raise(RuntimeError) do
      Animation.new([], TargetObject.new(0, 0, 0, 1, 1)){}
    end
    assert_raise(RuntimeError) do
      Animation.new([], TargetObject.new(0, 0, 0, 1, 1)){}
    end
  end

end
