require "test/unit"
require "dgo/interval/act"
require "dgo/interval/interval_runner"

class ActTest < Test::Unit::TestCase
  
  include DGO::Interval

  def test_hoge
  end

=begin
  def test_update
    x = 0
    act = Act.new do
      x += 1
    end

    runner = IntervalRunner.new(act)   
    
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

  def test_update2
    x = nil
    
    act = Act.new(5) do |counter|
      x = counter
    end
    
    runner = IntervalRunner.new(act)   

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
    assert(runner.done?)
    
    runner.update
    assert_equal(5, x)
    assert(runner.done?)
    
  end
=end
end
