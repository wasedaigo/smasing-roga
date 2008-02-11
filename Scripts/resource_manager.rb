require  "lib/graphics/animation_loader"
require "scenes/battle/skills/skill_loader"

include StarRuby
class ResourceManager
  def initialize(animeFileNames)
    @textures = {}
    @animation_frames = {}
    @text_data = {}
    @skills = {}
  end

  def get_animation_frame(id)
    if @animation_frames[id].nil?
      @animation_frames[id] = Graphics::AnimationLoader.load_animation("#{$data_path}/Data/Animations/#{id}.yaml")
    end
    return @animation_frames[id]
  end

  def get_skill(id)
    if @skills[id].nil?
      @skills[id] = SkillLoader.load_skill(id, "#{$data_path}/Data/battle/skills/#{id}.yaml")
    end
    return @skills[id]
  end
  
  def get_text_data(id)
    if @text_data[id].nil?
      str = ""
      File::open("Data/#{id}.rb", "r"){|f|str = f.read}
      @text_data[id] = str
    end
    return @text_data[id]
  end

  def get_texture(id)
    if @textures[id].nil?
      @textures[id] = Texture.load("#{$data_path}/Data/Images/#{id}")
    end
    return @textures[id]
  end
  
  def play_se(id)
    Audio.play_se("#{$data_path}/Data/Audio/Sound/#{id}")
  end
end
