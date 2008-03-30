require "test/unit"
require "func"
require "wait"
require "lerp"
require "parallel"
require "loop"
require "sequence"
require "interval_runner"
include Interval

class LoopTest < Test::Unit::TestCase

  def test_loop1
    x = 0
    loop = Loop.new(3, Sequence.new(Func.new{x += 1},Wait.new(1)))

    runner = IntervalRunner.new(loop) 
    
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
    assert_equal(3, x)
    assert(runner.done?)
  end
  
  def test_loop2
    x = 0
    loop = Loop.new(3, Sequence.new(Wait.new(1), Func.new{x += 1}))

    runner = IntervalRunner.new(loop) 
   
    runner.update
    assert_equal(0, x)
    assert(!runner.done?)
    
    runner.update
    assert_equal(1, x)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert(runner.done?)
  end
  
  def test_wait_loop
    x = y = z = 0
    loop = Loop.new(2, 
                    Sequence.new(
                      Wait.new(1){x += 1},
                      Wait.new(1){y += 1},
                      Wait.new(1){z += 1}
                    )
                   )

    runner = IntervalRunner.new(loop)

    runner.update
    assert_equal(1, x)
    assert_equal(0, y)
    assert_equal(0, z)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(1, y)
    assert_equal(0, z)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(1, y)
    assert_equal(1, z)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(1, y)
    assert_equal(1, z)
    assert(!runner.done?)
    p "------"
    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert_equal(1, z)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert_equal(2, z)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert_equal(2, z)
    assert(runner.done?)
  end
  
  def test_parallel_loop
    return
    x = y = z = 0
    parallel = Parallel.new(
                Loop.new(-1, Sequence.new(Wait.new(1){x += 1}, Wait.new(1){y += 1})),
                Wait.new(3){z += 1}
               )

    runner = IntervalRunner.new(parallel)  

    runner.update
    assert_equal(1, x)
    assert_equal(0, y)
    assert_equal(1, z)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(1, y)
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
