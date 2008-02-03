require "lib/interval/lerp"
require "lib/interval/interval_runner"
include Interval
class TransitionScene

  def initialize prev_state, next_state, transitions = []
    @prev_state = prev_state
    @next_state = next_state
    @alpha = 0
    @interval_runner= IntervalRunner.new(Lerp.new(55, 0, 255){|value|@alpha = value})
  end

  def update stack

    @interval_runner.update
    @next_state.update(stack, true)

    if @interval_runner.done?
      stack.pop
      stack.push(@next_state)
    end
  end

  def render(s)
    s.render_texture(@prev_state.get_texture, 0, 0, :alpha => 255 - @alpha)
    s.render_texture(@next_state.get_texture, 0, 0, :alpha => @alpha)
  end

end
