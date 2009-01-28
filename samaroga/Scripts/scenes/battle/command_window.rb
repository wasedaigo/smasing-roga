require "dgo/interval/func"
require "dgo/interval/lerp"
require "dgo/interval/sequence"
require "scenes/battle/icon"
require "dgo/interval/interval_runner"
include DGO::Interval

class CommandWindow
  attr_accessor :alpha, :tone
  FONT = Font.new("MS UI Gothic", 12, :bold => true)
  TIME = 3
  MARGIN = 16
  FRAME_SPACE = 5
  def initialize(x, y, battle_phase, unit, commands, controlable, options)
    @battle_phase = battle_phase
    @unit = unit
    @commands = []
    commands.each{|obj| obj[:opened] = true}
    @commands = commands.collect{|obj|{:command => obj[:command], :opened => obj[:opened], :open => obj[:opened]? 1.0 : 0.0}}
    
    
    @t_controlable = controlable
    @index = 0

    @x = x
    @y = y

    @src_height = 0
    @src_y = 0

    @close_interval = self.close_frame_interval
    @alpha = 255
    @tone = Tone.get_tone(0, 0, 0, 255)

    @controlable = false
    @interval_runner = IntervalRunner.new
    
    @func = proc do |value|
        @src_y = self.frame_texture.height - value
        @src_height = value
    end
    
    @options = options
    if @options[:mode] == :opened
      self.open
    end
  end

  def close_interval
    return @close_interval
  end
  
  def close_frame_interval
    return  Sequence.new(
              Wait.new(2),
              Lerp.new(TIME, self.frame_texture.height, 0) {|value| @func.call(value)},
              Func.new {@interval_runner = IntervalRunner.new}
            )
  end
  
  def discard_command_interval
    return Parallel.new(
          Lerp.new(6, 1.0, 0.0) do |value| 
            @commands[@index][:open] = value
          end,
          Wait.new(6){self.refresh}
        )
  end

  def open_interval
    return Sequence.new(open_frame_interval, Func.new{@controlable = @t_controlable}, add_command_interval)
  end
  
  def add_command_interval
    return Parallel.new(
      Sequence.new(
          Lerp.new(6, 0.0, 1.0) do |value| 
            @commands.select{|obj|!obj[:opened]}.each do |obj|
              obj[:open] = value
            end
          end
        )
    )
  end
  def open_frame_interval
    return Sequence.new(
      Lerp.new(TIME, 0, self.frame_texture.height) {|value| @func.call(value)}
    )
  end
  
  def close
    @interval_runner = IntervalRunner.new(self.close_interval)
  end
  
  def open
    @interval_runner = IntervalRunner.new(self.open_interval)
  end

  def selected_item
    return @commands[@index][:command]
  end
  
  def refresh
    self.update_content_texture
    self.update_texture
  end
  
  def update
    unless @interval_runner.done?
      @interval_runner.update
      self.refresh
      return
    end
    return unless @controlable
    
    if self.get_command_type(@index) != :unselectable
      if SimpleInput.pressed_newly?(:ok)
        if self.selected_item.usable?(@unit.grid_x)
          @close_interval = self.close_frame_interval
          $res.play_se("ok")
          yield :type => :ok, :value => @index
        end
        return
      end
    end
    
    if SimpleInput.pressed_newly?(:cancel) && @options[:selection_mode] == :all_selectable
       $res.play_se("cancel")
      if @unit.full_hand?
        @close_interval = Sequence.new(self.discard_command_interval, self.close_frame_interval)
      else
        @close_interval = self.close_frame_interval
      end
      yield :type => :cancel, :value => @index
      return
    end
  
    [:left, :right].each do |value|
      if SimpleInput.pressed_repeating?(value)
        yield :type => value, :value => @index
        return
      end
    end

    t = 0
    t = 1 if SimpleInput.pressed_repeating?(:down)
    t = -1 if SimpleInput.pressed_repeating?(:up)
    t = [[@index + t, @commands.size - 1].min, 0].max
    if t != @index
      $res.play_se("cursor")
      @index = t
      self.update_texture
      # yield :type => :move_cursor, :value => @index
      # return
    end
  end
  
  def render(s, x, y)
    s.render_texture(self.texture, x + @x + 7, y + @y + 20, {:alpha => @alpha, :src_y => @src_y, :src_height => @src_height}.merge(@tone)) 
    s.render_texture(self.title_texture, x + @x, y + @y)
  end
   
  def command_texture(no)
      type = self.get_command_type(no)
      
      if @command_textures.nil?
        @command_textures = {}
      end
      if @command_textures[no].nil?
        obj = @commands[no][:command]
        
        @command_textures[no] = {}
        
        [:default, :unselectable].each do |value|
          @command_textures[no][value] = Texture.new(90, 16)
          ICON.render_skill_icon(@command_textures[no][value], obj.group, 0, 0)
        end
        
        @command_textures[no][:default].render_shadow_text(obj.name, 15, 2, FONT, Color.new(33, 33, 33), Color.new(120, 120, 120, 50))
        @command_textures[no][:unselectable].render_shadow_text(obj.name, 15, 2, FONT, Color.new(100, 100, 100), Color.new(120, 120, 120, 50))
      end
      return @command_textures[no][type]
  end
  
  def content_texture
    if @content_texture.nil?
      self.update_content_texture
    end
    return @content_texture
  end
  
  def update_content_texture
    if @content_texture.nil?
      @content_texture = Texture.new(84, self.frame_texture.height)
    else
      @content_texture.clear
    end
    
    @commands.each_with_index do |obj, i|
      t = (self.command_texture(i).width * obj[:open]).floor
      @content_texture.render_texture(self.command_texture(i), self.command_texture(i).width - t, MARGIN * i, :src_width => t)
    end
  end
  
  def frame_texture
    if @frame_texture.nil?
      @frame_texture = Texture.new($res.get_texture("window/command_menu_box").width, @commands.length * MARGIN + 2 * FRAME_SPACE)
      @frame_texture.render_texture($res.get_texture("window/command_menu_box"), 0, 0, :src_height => @frame_texture.height, :src_y => $res.get_texture("window/command_menu_box").height - @frame_texture.height)
    end
    return @frame_texture
  end

  def title_texture
    self.update_title_texture if @title_texture.nil?
    return @title_texture
  end
  
  def update_title_texture
    @title_texture = $res.get_texture("window/command_menu_title").dup
    unless @unit.nil?
      @title_texture.render_texture(@unit.icon_texture, 2, 2)
      @title_texture.render_shadow_text(@unit.name.to_s, 30, 4, FONT, Color.new(33, 33, 33), Color.new(0, 0, 0, 50))
    end
  end
  
  def texture
    if @texture.nil?
      self.update_texture
    end
    return @texture
  end
  
  def update_texture
    @texture = Texture.new(113, 86)
    @texture.render_texture(self.frame_texture, 0, 0) unless @commands.empty?
    if @controlable
      @texture.render_texture($res.get_texture("window/command_menu_select"), 7, FRAME_SPACE + MARGIN * @index)
      @texture.render_texture($res.get_texture("window/command_menu_cursor"), 3, FRAME_SPACE + MARGIN * @index)
    end
    @texture.render_texture(self.content_texture, 13, FRAME_SPACE)
  end
  
  def get_command_type(no)
      return :unselectable if @options[:selection_mode] == :all_unselectable
      if (@unit.group == :battler && !@commands[no][:command].usable?(@unit.grid_x))|| (@options[:selection_mode] == :chain_skill_selectable && @commands[no][:command].group != :attack)
        return :unselectable
      end
      return :default
  end
end