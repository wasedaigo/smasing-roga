module DGO
  module Gadgets
    class Window

      attr_reader :width, :height
      attr_reader :content_texture, :grid_size
      attr_accessor :x, :y, :visible

      def initialize(x, y, width, height, texture, grid_size)
        @x = x
        @y = y

        @grid_size = grid_size
        @width = [(width / @grid_size.to_f).ceil * @grid_size, @grid_size].max + @grid_size
        @height = [(height / @grid_size.to_f).ceil * @grid_size, @grid_size].max + @grid_size

        @texture = texture
        @visible = true
      end

      def content_texture
        if @content_texture.nil?
          @content_texture = Texture.new(@width - @grid_size, @height - @grid_size)
        end
        @content_texture
      end

      def frame_texture
        if @frame_texture.nil?
          half = @grid_size / 2
          @frame_texture = Texture.new(@width, @height)

          last_i = @width / @grid_size
          last_j = @height / @grid_size

          (0..last_j).each do |j|
            (0..last_i).each do |i|

              case i
              when 0
                src_x     = 0
                src_width = half
              when last_i
                src_x     = half * 3
                src_width = half
              else
                src_x     = half
                src_width = @grid_size
              end

              case j
              when 0
                src_y      = 0
                src_height = half
              when last_j
                src_y      = half * 3
                src_height = half
              else
                src_y      = half
                src_height = @grid_size
              end

              x = [i * @grid_size - half, 0].max
              y = [j * @grid_size - half, 0].max
              @frame_texture.render_texture(@texture, x, y,
                                            :src_x => src_x, :src_y => src_y, :src_width => src_width, :src_height => src_height)
            end
          end
        end
        @frame_texture
      end

      def render(s, x = 0, y = 0, options = {})
        s.render_texture(frame_texture, x + @x, y + @y, options)
        s.render_texture(content_texture, x + @x + @grid_size / 2, y + @y + @grid_size / 2, options)
      end

    end
  end
end
