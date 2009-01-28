module Waitable
  attr_reader :wait_time, :max_time
  def initialize_wait(max_time)
    @max_time = max_time
    @wait_time = @max_time
  end

  def reset_wait_time
    @wait_time = @max_time
  end
end