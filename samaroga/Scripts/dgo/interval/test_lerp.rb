require "test/unit"
require "dgo/interval/func"
require "dgo/interval/wait"
require "dgo/interval/lerp"
require "dgo/interval/interval_runner"

class LerpTest < Test::Unit::TestCase

  include DGO::Interval

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
