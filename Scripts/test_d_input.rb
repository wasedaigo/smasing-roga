
require "test/unit"
require "d_input"
class DInputTest < Test::Unit::TestCase
  def test_swap_key
    assert_equal(:escape, DInput.swap_key(:cancel))
    assert_equal(:space, DInput.swap_key(:ok))
  end
end
