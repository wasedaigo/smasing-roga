require "dgo/target_object"
module DGO
  module Graphics
   class Animation
      attr_reader :depth, :duration
      def initialize(animation_frames, target, options = {}, &call_back)
        raise("no animation frame was passed") if animation_frames.empty?

        @animation_frames = animation_frames
        @target = target
        
        @fixed = options[:fixed] ? options[:fixed] : false
        @fixed_target = TargetObject.new(@target.x, @target.y, @target.z, @target.width, @target.height)
        @frame_rate = options[:frame_rate] ? options[:frame_rate] : 1.0
        @offset_x = options[:offset_x] ? options[:offset_x] : 0
        @offset_y = options[:offset_y] ? options[:offset_y] : 0
        @swap_textures = options[:swap_textures] ? options[:swap_textures] : []

        proc = proc do |frame| 
                          @frame = frame 
                          call_back.call(self)
                         end
        arr = []
        @animation_frames.each do |frame|
          arr << frame.generate_interval(proc)
        end
        @interval = Sequence.new(arr)
      end

      def depth
        return @interval.depth
      end
      
      def duration
        return @interval.duration
      end
      
      def call(node)
        return @interval.call(node)
      end

      def render(s, x, y)
        unless @frame.nil?
          if @fixed
            @frame.render(s, @fixed_target, @offset_x + x, @offset_y + y, @swap_textures)
          else
            @frame.render(s, @target, @offset_x + x, @offset_y + y, @swap_textures)
          end
        end
      end
    end
  end
end