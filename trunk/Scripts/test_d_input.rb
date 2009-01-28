
require "test/unit"
require "simple_input"
class SimpleInputTest < Test::Unit::TestCase
  def test_swap_key
    assert_equal(:escape, SimpleInput.swap_key(:cancel))
    assert_equal(:space, SimpleInput.swap_key(:ok))
  end
end
