require "test/unit"
require "dgo/interval/func"
require "dgo/interval/interval_runner"

class FuncTest < Test::Unit::TestCase
  
  include DGO::Interval

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
