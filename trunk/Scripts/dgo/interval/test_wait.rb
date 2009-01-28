require "test/unit"
require "dgo/interval/wait"
require "dgo/interval/interval_runner"

class WaitTest < Test::Unit::TestCase

  include DGO

  def test_update
    x = nil
    
    wait = Interval::Wait.new(5) do |counter|
      x = counter
    end
    
    runner = Interval::IntervalRunner.new(wait)   

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
    assert_equal(5, x)
    assert(!runner.done?)
    
    runner.update
    assert_equal(5, x)
    assert(runner.done?)
    
  end

end
