require "lib/interval/parallel"
include Interval
module Graphics
  class AnimationFrame
    def initialize(duration, sprites = [], effects = [])
      raise("duration must be more than 0") if duration <= 0
      @duration = duration
      @effects = effects
      @sprites = sprites
    end
    
    def generate_interval(call_back)
      arr = []
      @effects.each {|effect| arr << effect}
      @interval = Parallel.new(
                    Wait.new(@duration){call_back.call(self)},
                    arr
                  )
      return @interval
    end

    def render(s, target, x, y, swap_textures)
      swap_textures.each do |obj|
        @sprites.select{|sprite|sprite.texture_id == obj[:from_id]}.each do |sprite|
          sprite.swap_texture($res.get_texture(obj[:to_id]), obj[:to_id])
        end
      end

      @sprites.each do |obj|
        obj.render(s, x + target.center_x - obj.width/2, y + target.center_y - obj.height/2 - target.z)
      end
      
      swap_textures.each do |obj|
        @sprites.select{|sprite|sprite.texture_id == obj[:to_id]}.each do |sprite|
          sprite.swap_texture($res.get_texture(obj[:from_id]), obj[:from_id])
        end
      end
    end
  end
end
