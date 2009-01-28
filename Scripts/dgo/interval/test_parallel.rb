require "test/unit"
require "dgo/interval/wait"
require "dgo/interval/func"
require "dgo/interval/parallel"
require "dgo/interval/sequence"
require "dgo/interval/interval_runner"

class ParallelTest < Test::Unit::TestCase

  include DGO
  include DGO::Interval

  def test_update

    x = y = z = nil
    wait1 = Wait.new(3) do |counter|
      x = counter
    end
    wait2 = Wait.new(5) do |counter|
      y = counter
    end
    wait3 = Wait.new(7) do |counter|
      z = counter
    end
    func = Interval::Func.new do
      z = 100
    end
    parallel = Parallel.new(wait1, wait2, wait3, func)
    runner = IntervalRunner.new(parallel)
    
    runner.update
    assert_equal(1, x)
    assert_equal(1, y)
    assert_equal(100, z)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert_equal(2, z)
    assert(!runner.done?)

    runner.update
    assert_equal(3, x)
    assert_equal(3, y)
    assert_equal(3, z)
    assert(!runner.done?)

    runner.update
    assert_equal(3, x)
    assert_equal(4, y)
    assert_equal(4, z)
    assert(!runner.done?)

    runner.update
    assert_equal(3, x)
    assert_equal(5, y)
    assert_equal(5, z)
    assert(!runner.done?)

    runner.update
    assert_equal(3, x)
    assert_equal(5, y)
    assert_equal(6, z)
    assert(!runner.done?)

    runner.update
    assert_equal(3, x)
    assert_equal(5, y)
    assert_equal(7, z)
    assert(!runner.done?)
   
    runner.update
    assert_equal(3, x)
    assert_equal(5, y)
    assert_equal(7, z)
    assert(runner.done?)
  end
  
  def test_parallel_wait
    x = y = 0
    parallel =  Parallel.new(
                  Wait.new(3){|value|x = value},
                  Wait.new(-1){|value|y = value}
                )
    runner = IntervalRunner.new(parallel)
    
    runner.update
    assert_equal(1, x)
    assert_equal(1, y)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert(!runner.done?)
    
    runner.update
    assert_equal(3, x)
    assert_equal(3, y)
    assert(!runner.done?)
    
    runner.update
    assert_equal(3, x)
    assert_equal(3, y)
    assert(runner.done?)
  end
  
  def test_parallel_sequence
    x = y = z =0
    parallel =  Parallel.new(
                  Sequence.new(Wait.new(2){|value|x = value}, Func.new{y += 1}),
                  Wait.new(3){|value|z = value}
                )
    runner = IntervalRunner.new(parallel)
    
    runner.update
    assert_equal(1, x)
    assert_equal(0, y)
    assert_equal(1, z)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(0, y)
    assert_equal(2, z)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(1, y)
    assert_equal(3, z)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(1, y)
    assert_equal(3, z)
    assert(runner.done?)
  end

end
