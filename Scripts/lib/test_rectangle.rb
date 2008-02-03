$LOAD_PATH << "../"

require "test/unit"
require "rectangle"
class RectangleTest < Test::Unit::TestCase
  def test_all
    r = Rectangle.new(6, -4, 32, 32)
    assert_equal(r.left, 6)
    assert_equal(r.top, -4)
    assert_equal(r.right, 38)
    assert_equal(r.bottom, 28)
    assert_equal(r.width, 32)
    assert_equal(r.height, 32)

    assert_raise RuntimeError do
      Rectangle.new(6, -4, -1, 32)
    end

    assert_raise RuntimeError do
      Rectangle.new(6, -4, 32, -1)
    end

    assert_raise RuntimeError do
      Rectangle.new(6, -4, -1, 0)
    end
  end
end
