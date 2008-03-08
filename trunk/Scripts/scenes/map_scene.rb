require  "scenes/map/character"
require  "scenes/map/character_chip"
require  "scenes/map/character_chipset"
require  "scenes/map/map"
require  "scenes/map/map_chipset"
require  "scenes/map/auto_map_chipset"
require  "scenes/map/collision_type"
require  "scenes/map/character_speed_type"
require  "scenes/map/map_loader"
require  "scenes/map/config"
require  "lib/gadgets/baloon_message_window"
require  "lib/table"
require  "d_input"

require "scenes/transitionable"
include Transitionable
include SRoga

class MapScene

  # Define ChipSets
  TestPlayerChipSet = SRoga::CharacterChipset.new "test", 16, 16, 3, Rectangle.new(0, 0, 16, 16)
  SaruChipset = CharacterChipset.new "saru", 32, 32, 3, Rectangle.new(8, 16, 16, 16)
  PlayerChipset = CharacterChipset.new "player", 24, 32, 3, Rectangle.new(4, 16, 16, 16)

  # Define Character Chips
  SaruChip = CharacterChip.new SaruChipset,0,0
  PlayerChip = CharacterChip.new PlayerChipset,0,0

  TestPlayerChip1 = CharacterChip.new(TestPlayerChipSet, 0, 0)
  TestPlayerChip2 = CharacterChip.new(TestPlayerChipSet, 1, 0)
  TestPlayerChip3 = CharacterChip.new(TestPlayerChipSet, 2, 0)
  TestPlayerChip4 = CharacterChip.new(TestPlayerChipSet, 3, 0)
  TestPlayerChip5 = CharacterChip.new(TestPlayerChipSet, 0, 1)
  TestPlayerChip6 = CharacterChip.new(TestPlayerChipSet, 1, 1)
  TestPlayerChip7 = CharacterChip.new(TestPlayerChipSet, 2, 1)
  TestPlayerChip8 = CharacterChip.new(TestPlayerChipSet, 3, 1)

  #TestMapChipset = MapChipset.new "ChipSet", 16
  TestMapChipset2 = AutoMapChipset.new("ChipSet2", 16)
  TestMapChipset = MapChipset.new("ChipSet", 16)

  def initialize
    tx = 0
    ty = 0
    @charaList = []
    @player = Character.new(PlayerChip, 1, 20 - tx, 20 - ty, CharacterSpeedType::NORMAL, true)
    @charaList << @player
    @charaList << Character.new(TestPlayerChip2, 2, 11 - tx, 16 - ty, CharacterSpeedType::SLOW, false)
    @charaList << Character.new(TestPlayerChip3, 3, 13 - tx, 18 - ty, CharacterSpeedType::VERY_SLOW, false)
    @charaList << Character.new(TestPlayerChip4, 4, 14 - tx, 22 - ty, CharacterSpeedType::NORMAL, false)
    @charaList << Character.new(TestPlayerChip5, 5, 11 - tx, 16 - ty, CharacterSpeedType::FAST, false)
    @charaList << Character.new(TestPlayerChip6, 6, 13 - tx, 16 - ty, CharacterSpeedType::NORMAL, false)
    @charaList << Character.new(TestPlayerChip7, 7, 18 - tx, 22 - ty, CharacterSpeedType::VERY_FAST, false)
    @charaList << Character.new(TestPlayerChip8, 8, 16 - tx, 22 - ty, CharacterSpeedType::NORMAL, false)
    @saru = Character.new(SaruChip, 9, 21 - tx, 22 - ty, CharacterSpeedType::NORMAL, false)
    @charaList << @saru

    # make map
    data = MapLoader.loadMap
    @map =  Map.new(data[:wCount], data[:hCount], 20, 15, data[:collisionData], 0  => TestMapChipset, 1  => TestMapChipset2)
    @bottom_layer = MapLayer.new @map, data[:bottomLayer]
    @top_layer = MapLayer.new @map, data[:topLayer]

    @base_x = 0
    @base_y = 0
    @showWidth = 320
    @showHeight = 240

    gs = BaloonWindow::GRID_SIZE
    @window = BaloonMessageWindow.new(@player.centerX - @map.base_x, @player.renderY - @map.base_y, gs * 8, gs * 1, "よく分かりません・・。")
    @window2 = BaloonMessageWindow.new(@player.centerX - @map.base_x, @player.renderY - @map.base_y, gs * 5, gs * 3, "最初から 続きから 終了")
  end

  # Caliculate the base render position(Top-Left)
  def caliculateBase x, y
    tx = x - SRoga::Config::GRID_SIZE * ((( @showWidth)/2 ) / SRoga::Config::GRID_SIZE)
    ty = y - SRoga::Config::GRID_SIZE * ((( @showHeight)/2 ) / SRoga::Config::GRID_SIZE)

    if tx < 0
      tx = 0
    end
    if ty < 0
      ty = 0
    end
    if tx >= @map.width - @showWidth
      tx = @map.width - @showWidth
    end
    if ty >= @map.height - @showHeight
      ty = @map.height - @showHeight
    end

    @map.base_x = tx
    @map.base_y = ty
  end

  def update(stack = [], transition = false)

    @map.reset_object_collisions
    @map.reset_object_ids

    @charaList.each do |obj|
      @map.set_object_collision obj.mapX, obj.mapY, CollisionType::ALL
    end

    @charaList.each do |obj|
      if obj != @player
        t = []

        case rand(4)
        when 0
          t << :up
        when 1
          t << :right
        when 2
          t << :down
        when 3
          t << :left
        end

        obj.set_movement t
      else
        t = []
        [:left, :right, :up, :down].each do |key|
          t << key if DInput.pressed? key
        end
        obj.set_movement t
      end
    end

    @charaList.each do |obj|
      obj.move @map
    end

    @charaList.each do |obj|
      @map.set_object_id obj.mapX, obj.mapY, obj.id
    end

    @charaList.each do |obj|
      @window.visible = true if obj.update @map
    end

    #Choose Focus Object which you want to make as the center of the screen
    self.caliculateBase @player.x, @player.y

    @map.update @showWidth , @showHeight, [@bottom_layer, @top_layer]
    @window.update(@player.centerX - @map.base_x, @player.renderY - @map.base_y, @showWidth , @showHeight)

    # back to title
    stack.pop if DInput.pressed? :cancel
  end

  def zoom(s, zoom)
    tx = @player.centerX - @map.base_x
    ty = @player.renderY - @map.base_y

    tx2 = tx - @showWidth / (2 * zoom)
    ty2 = ty - @showHeight / (2 * zoom)

    tx2 = 0 if tx2<0
    ty2 = 0 if ty2<0
    tx2 =  @showWidth / zoom if tx2 >@showWidth / zoom
    ty2 =  @showHeight / zoom if ty2 >@showHeight / zoom

    s.render_texture s, 0, 0, :src_x=>tx2, :src_y=>ty2, :src_width=>@showWidth/zoom, :src_height=>@showHeight/zoom, :scale_x=>zoom, :scale_y=>zoom
  end

  def render(s)
    s.clear
    @map.render(s, @bottom_layer)

    @charaList.each{|obj|obj.render(s, @map.base_x, @map.base_y)}

    #@map.render s, @top_layer

    #@window.render(s)

    #s.render_texture($res.get_texture("background"),20,0)
  end

end
