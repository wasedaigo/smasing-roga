class Color
  Black = Color.new(0, 0, 0, 255)
  Blue = Color.new(0, 0, 255, 255)
  Green = Color.new(0, 255, 0, 255)
  Red = Color.new(255, 0, 0, 255)
  SkyBlue = Color.new(120, 120, 255, 255)
  White = Color.new(255, 255, 255, 255)
  Yellow = Color.new(255, 255, 0, 255)
end

class Tone
  def self.get_tone(red, green, blue, saturation)
    return {:tone_red => red, :tone_green => green, :tone_blue => blue, :saturation => saturation}
  end

  Black = self.get_tone(-255, -255, -255, 255)
  Blue = self.get_tone(-255, -255, 0, 255)
  Green = self.get_tone(0, 255, 0, 255)
  Red = self.get_tone(0, -155, -155, 255)
  SkyBlue = self.get_tone(-100, -100, 0, 255)
  White = self.get_tone(0, 0, 0, 255)
  Yellow = self.get_tone(0, 0, -255, 255)
end

class Font
  def self.get_number_font_size(font_type)
    case font_type
      when :medium_numbers
        width = 10
        height = 10
        texture = $res.get_texture("medium_numbers")
      when :small_numbers
        width = 6
        height = 10
        texture = $res.get_texture("small_numbers")
      else
        raise("this must not be called")
    end
    return [width, height, texture]
  end
end

class Texture
  def render_edge_text(text, x, y, font, color, edge_color)
    self.render_text(text, x, y + 1, font, edge_color)
    self.render_text(text, x + 1, y, font, edge_color)
    self.render_text(text, x + 2, y + 1, font, edge_color)
    self.render_text(text, x + 1, y + 2, font, edge_color)
    self.render_text(text, x + 1, y + 1, font, color)
  end

  def render_shadow_text(text, x, y, font, color, shade_color)
    
    w, h = font.get_size(text)
    t = Texture.new(w, h)
    self.render_text(text, x + 1, y, font, shade_color)
    self.render_text(text, x, y + 1, font, shade_color)
    self.render_text(text, x, y, font, color)
  end

  def self.get_number_texture(value, font_type, options)
    size = self.get_number_size(value, font_type)
    texture = Texture.new(size[0], size[1])
    texture.render_number(value, 0, 0, font_type, options)
    return texture
  end

  def self.get_number_size(value, font_type)
    arr = value.to_s.split(/ */)
    width, height = Font.get_number_font_size(font_type)
    return [width * arr.length, height]
  end

  def render_number(value, x, y, font_type, options = {})
    width, height, texture = Font.get_number_font_size(font_type)
    arr = value.to_s.split(/ */)
    
    arr.each_with_index do |value, i|
      case value
        when "-"
          options[:src_x] = width * 10
        when "/"
          options[:src_x] = width * 11
        else
          options[:src_x] = width * value.to_i
      end
      options[:src_width] = width
      options[:src_height] = height
      self.render_texture(texture, x + width * i, y, options)
    end
  end
end
