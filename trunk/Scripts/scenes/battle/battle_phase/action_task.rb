require "dgo/interval/interval_runner"
include DGO::Interval

class ActionTask
  def initialize(interval)
    @interval_runner = IntervalRunner.new(interval)
  end

  def done?
    @interval_runner.done?
  end

  def update(tasks)
    @interval_runner.update
  end
end
