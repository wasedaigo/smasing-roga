require "test/unit"
require "sequence"
require "wait"
require "func"
require "interval_runner"
include Interval

class SequenceTest < Test::Unit::TestCase
  

  def test_update
    t = Sequence.new()
    runner = IntervalRunner.new(t)
    runner.update

    x = y = z = w = v = nil
    wait1 = Wait.new(3) do |counter|
      x = counter - 1
    end
    func = Func.new do
      w = 1
    end
    wait2 = Wait.new(5) do |counter|
      y = counter - 1
    end
    wait3 = Wait.new(7) do |counter|
      z = counter - 1
    end

    wait4 = Wait.new(2) do |counter|
      x = counter - 1
    end

    wait5 = Wait.new(3) do |counter|
      y = counter - 1
    end

    sequence = Sequence.new(
    wait1,
    wait2,
    func,
    func,
    wait3,
    Func.new{v = 100},
    Sequence.new(
    wait4,
    wait5
    ),
    wait1
    )

    runner = IntervalRunner.new(sequence)
    (0..10).each do
      runner.reset
      until runner.done?
        runner.update
      end
    end
    
    (0..0).each do
    x = y = z = w = v = nil
    runner.reset
    runner.update

    assert_equal(0, x)
    assert_equal(nil, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(nil, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(nil, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(0, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(1, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)

    assert(!runner.done?)
    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(3, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(0, z)
    assert_equal(1, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(1, z)
    assert_equal(1, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(2, z)
    assert_equal(1, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(3, z)
    assert_equal(1, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(4, z)
    assert_equal(1, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(5, z)
    assert_equal(1, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(2, x)
    assert_equal(4, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(0, x)
    assert_equal(4, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(4, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)
    assert(!runner.done?)
    
    runner.update
    assert_equal(1, x)
    assert_equal(0, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(1, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(2, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)
    runner.update
    assert_equal(0, x)
    assert_equal(2, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(1, x)
    assert_equal(2, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(2, y)
    assert_equal(6, z)
    assert_equal(1, w)
    assert_equal(100, v)
    assert(runner.done?)

    
    x = y = z = w = v = nil

    runner.reset
    runner.update
    assert_equal(0, x)
    assert_equal(nil, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(nil, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)
    
    runner.reset
    runner.update
    assert_equal(0, x)
    assert_equal(nil, y)
    assert_equal(nil, z)
    assert_equal(nil, w)
    assert_equal(nil, v)
    assert(!runner.done?)
    end
  end
end
