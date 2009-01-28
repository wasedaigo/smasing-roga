require "test/unit"
require "func"
require "wait"
require "lerp"
require "interval_runner"
include Interval

class LerpTest < Test::Unit::TestCase

  def test_update
    x = nil

    lerp = Lerp.new(4, 0, 4) do |value|
      x = value
    end

    runner = IntervalRunner.new(lerp)  

    runner.update
    assert_equal(1, x)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert(!runner.done?)

    runner.update
    assert_equal(3, x)
    assert(!runner.done?)

    runner.update
    assert_equal(4, x)
    assert(!runner.done?)

    runner.update
    assert_equal(4, x)
    assert(runner.done?)
  end

end
