require "test/unit"
require "func"
require "interval_runner"
include Interval

class FuncTest < Test::Unit::TestCase
  def test_update
    x = 0
    func = Func.new do
      x += 1
    end

    runner = IntervalRunner.new(func)   
    
    runner.update
    assert_equal(1, x)
    assert(runner.done?)

    runner.reset
    runner.update
    assert_equal(2, x)
    assert(runner.done?)

    runner.reset
    runner.update
    assert_equal(3, x)
    assert(runner.done?)
  end
end
