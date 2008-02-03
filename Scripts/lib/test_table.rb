$LOAD_PATH << "../"

require "test/unit"
require "table"
class TableTest < Test::Unit::TestCase

  def test_width
    table = Table.new 4, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal 4, table.width
    assert_equal 3, table.height
    assert_equal [4, 3], table.size
    table = Table.new 2, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    assert_equal 2, table.width
    assert_equal 6, table.height
    assert_equal [2, 6], table.size
  end

  def test_index
    table = Table.new 2, [1, 2, 3, 4, 5, 6, 7, 8]
    assert_equal 1, table[0, 0]
    assert_equal 4, table[1, 1]
    assert_equal 5, table[0, 2]
    assert_equal 8, table[1, 3]
    assert_raise IndexError do
      table[2, 0] = 0
    end
    assert_raise IndexError do
      table[-1, 0] = 0
    end
    assert_raise IndexError do
      table[0, 4] = 0
    end
    assert_raise IndexError do
      table[0, -1] = 0
    end
  end

  def test_marshal
    table = Table.new 4, [1, 2, 3, 4, 5, 6, 7, 8]
    table = Marshal.load(Marshal.dump(table))

    assert_equal 4, table.width
    assert_equal 2, table.height
    assert_equal 1, table[0, 0]
    assert_equal 3, table[2, 0]
    assert_equal 6, table[1, 1]
    assert_equal 8, table[3, 1]
  end
end
