require "yaml"
require "dgo/graphics/sprite"
require "dgo/graphics/animation_frame"
require "dgo/graphics/animation"
require "dgo/interval/interval_lib"
include DGO::Interval

  module DGO
  module Graphics
    class AnimationLoader
   
      def self.load_animation(filename)

        arr = []
        str = ""
        File.open(filename, "r") {|f| str = f.read}
        YAML::load(str).each do |frame|
        
          sprites = []
          unless frame["sprites"].nil?
            frame["sprites"].each do |sprite|
              texture = $res.get_texture(sprite["id"])

              options = {
              :src_x=>sprite["src_x"].to_i, 
              :src_y=>sprite["src_y"].to_i,
              :src_width=>sprite["width"].to_i, 
              :src_height=>sprite["height"].to_i
              }

              options[:texture_id] = sprite["id"]
              options[:center_x] = sprite["center_x"].to_i unless sprite["center_x"].nil?
              options[:center_y] = sprite["center_y"].to_i unless sprite["center_y"].nil?
              options[:angle] = Math::PI * (2 * sprite["angle"].to_i / 360.0) unless sprite["angle"].nil?
              options[:alpha] = sprite["alpha"].to_i unless sprite["alpha"].nil?
              options[:tone_red] = sprite["tone_red"].to_i unless sprite["tone_red"].nil?
              options[:tone_green] = sprite["tone_green"].to_i unless sprite["tone_green"].nil?
              options[:tone_blue] = sprite["tone_blue"].to_i unless sprite["tone_blue"].nil?
              options[:saturation] = sprite["saturation"].to_i unless sprite["saturation"].nil?
              sprites.push(Sprite.new(texture, sprite["x"].to_i, sprite["y"].to_i, options))
            end
          end
          
          effects = []
          unless frame["effects"].nil?
            frame["effects"].each do |effect|
              effects.push(Interval.get_sound_interval(effect["se"], :volume => 50)) unless effect["se"].nil?
            end
          end
          
          arr << AnimationFrame.new(frame["duration"].to_i, sprites, effects)
        end

        return arr
      end
    end
  end
end
