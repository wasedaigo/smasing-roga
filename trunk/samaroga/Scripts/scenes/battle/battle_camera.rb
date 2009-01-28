require "dgo/target_object"
require "dgo/interval/sequence"
require "dgo/interval/parallel"
require "dgo/interval/sequence"
require "dgo/interval/lerp"
include DGO::Interval

class BattleCamera
  attr_reader :render_list
  def initialize(render_list)
    @zoom = 1
    @target = TargetObject.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0, 0, 0)
    @center_x = @target.x
    @center_y = @target.y
    @interval = Sequence.new
    @render_list = render_list
  end
  
  def get_focus_interval(time, zoom, target = nil)
  
    target = TargetObject.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0, 0, 0) if target.nil?
    return  Lerp.new(time, 0.0, 1.0) do |value|
              t_zoom = @zoom if t_zoom.nil?
              tx = @target.center_x if tx.nil?
              ty = @target.center_y - @target.z if ty.nil?
              @zoom = t_zoom + (zoom - t_zoom) * value
              @target.x = (tx + (target.center_x - tx) * value).round
              @target.y = (ty + (target.center_y - target.z - ty) * value).round
            end
  end

  def update
    @render_list.clear
    # unless @interval.done?
      # @interval.update
    # end
  end
  
  def render(s)
      tx = SCREEN_WIDTH / 2
      ty = SCREEN_HEIGHT / 2
      ss = [[ty - @target.y, 0].max, ty].min
      @render_list.render(s, [[tx - @target.x, 0].max, tx].min, [[ty - @target.y, 0].max, ty].min)

      unless @zoom == 1
        s.render_texture(s, 0, 0, 
        :scale_x => @zoom, 
        :scale_y => @zoom, 
        :src_x => 0,
        :src_y => 0,
        :src_width => s.width, 
        :src_height => s.height,
        :center_x => @center_x,
        :center_y => @center_y
        )
      end
      
      @render_list.render(s, 0, 0, :render_over_top)
  end
end