require  "d_input"

class LossPhase
  def initialize(base)
    @base = base
  end

  def update(queue)
    @base.render_list.register(@commandSelection, :top)
  end
end
