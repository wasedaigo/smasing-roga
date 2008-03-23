require "starruby"
include StarRuby

require "test/unit"
require "scripts/map"
require "scripts/cursor"

class CursorTest < Test::Unit::TestCase

  def test_update
    map = Map.new
    cursor = Cursor.new(map)
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(-2, 2)
    assert_equal(4, x)
    assert_equal(0, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(-1, 1)
    assert_equal(2, x)
    assert_equal(0, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(-1, 2)
    assert_equal(3, x)
    assert_equal(1, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(0, 0)
    assert_equal(0, x)
    assert_equal(0, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(0, 1)
    assert_equal(1, x)
    assert_equal(1, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(0, 2)
    assert_equal(2, x)
    assert_equal(2, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(1, 2)
    assert_equal(1, x)
    assert_equal(3, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(2, 2)
    assert_equal(0, x)
    assert_equal(4, y)
    
    x, y = cursor.convert_screen_coordinate_to_isometric_coordinate(2, 3)
    assert_equal(1, x)
    assert_equal(5, y)
  end

end
