class TargetPoint
  attr_reader :grid_x, :grid_y
  attr_accessor :select_state, :selected
  def initialize(grid_x, grid_y)
    @grid_x = grid_x
    @grid_y = grid_y
    @selected = false
    @select_state = :none
  end
end