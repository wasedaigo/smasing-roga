require "test/unit"
require "dgo/interval/wait"
require "dgo/interval/func"
require "dgo/interval/lerp"
require "dgo/interval/parallel"
require "dgo/interval/sequence"
require "dgo/interval/interval_runner"

class IntervalRunnerlTest < Test::Unit::TestCase

  include DGO::Interval

  def test_update

    v = x = y = z = 0
    seq = Sequence.new(
      Parallel.new(
        Func.new{x += 1},
        Sequence.new(
          Wait.new(3){y += 1},
          Sequence.new(
            Wait.new(1){z += 1},
            Parallel.new(
              Parallel.new(
                Func.new{v += 1},
                Wait.new(3){v += 1}
              ),
              Lerp.new(3, 0, 3){|value|x = value},
              Sequence.new(
                Wait.new(2){v += 1}
              )
            )
          )
        )
      )
    )
    
    runner = IntervalRunner.new(seq)
    
    runner.update
    assert_equal(1, x)
    assert_equal(1, y)
    assert_equal(0, z)
    assert_equal(0, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(1, x)
    assert_equal(2, y)
    assert_equal(0, z)
    assert_equal(0, v)
    assert(!runner.done?)

    runner.update
    assert_equal(1, x)
    assert_equal(3, y)
    assert_equal(0, z)
    assert_equal(0, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(1, x)
    assert_equal(3, y)
    assert_equal(1, z)
    assert_equal(0, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(1, x)
    assert_equal(3, y)
    assert_equal(1, z)
    assert_equal(3, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(2, x)
    assert_equal(3, y)
    assert_equal(1, z)
    assert_equal(5, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(3, x)
    assert_equal(3, y)
    assert_equal(1, z)
    assert_equal(6, v)
    assert(!runner.done?)
    
    runner.update
    assert_equal(3, x)
    assert_equal(3, y)
    assert_equal(1, z)
    assert_equal(6, v)
    assert(runner.done?) 
  end

end
