require 'wx'
require 'starruby'
include StarRuby

require 'yaml'
require 'yaml/store'

module StarRuby
  class Texture
    def bitmap
      return Wx::Bitmap.new(self.image)
    end
    
    def image
      image = Wx::Image.new(self.width, self.height)
      image.data = self.dump("rgb")
      return image
    end
  end
end

module Wx  
  class DC
    def draw_texture(texture, x, y)
      draw_bitmap(texture.bitmap, x, y, false)
    end
  end
end

def ico_bitmap(base_name)

  ico_file = File.join( File.dirname(__FILE__), 'icons', base_name )
  Wx::Bitmap.new(ico_file, Wx::BITMAP_TYPE_XPM)
end
    
$LOAD_PATH << "../../Scripts/"
$data_path = "../../"
SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240
require  "resource_manager"
$res = ResourceManager.new("Data/anime_file.csv")
require "extension"
require "scenes/map_scene"
require "scenes/battle_scene"
require  "scenes/map/map"
require  "scenes/map/map_layer"
require  "scenes/map/map_chipset"
require  "scenes/map/auto_map_chipset"

require "model_editor"
require "model"
require "controller"
require "map_panel"
require "palet_panel"
require "auto_tile_palet_panel"
require "normal_tile_palet_panel"

PALET_ROW_COUNT = 8

module DRPGTool
  class MainFrame < Wx::Frame
    def initialize(title)
      super(nil, :title => title, :size => [800, 600])
      center(Wx::BOTH)

      # menu bar
      menu_help = Wx::Menu.new
      menu_bar = Wx::MenuBar.new
      menu_bar.append(menu_help, "&Help")
      self.menu_bar = menu_bar
            
      # status bar
      self.create_status_bar
      
      # tool bar
      tool_bar = create_tool_bar(Wx::TB_HORIZONTAL | Wx::NO_BORDER | Wx::TB_FLAT)    
      
      #setup_panels
      splitter = Wx::SplitterWindow.new(self)
      
      panel = Wx::Panel.new(splitter)
      panel.sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      @auto_tile_palet_panel = AutoTilePaletPanel.new(panel, 2, Wx::Size.new(PALET_ROW_COUNT * 32, 160))
      @normal_tile_palet_panel = NormalTilePaletPanel.new(panel, 2, Wx::Size.new(PALET_ROW_COUNT * 32, 900))
      
      panel.sizer.add(@auto_tile_palet_panel, 1, Wx::EXPAND)
      panel.sizer.add(@normal_tile_palet_panel, 1, Wx::EXPAND)
      
      editor_panel = Wx::Panel.new(splitter)
      editor_panel.sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      @map_panel = MapPanel.new(editor_panel, 2, Wx::Size.new(960,640), { 0 => @auto_tile_palet_panel, 1 => @normal_tile_palet_panel})
      editor_panel.sizer.add(@map_panel, 1, Wx::EXPAND)
      
      @auto_tile_palet_panel.evt_left_down do |e|
        @map_panel.using_palet_no = 0
        @auto_tile_palet_panel.on_left_down(e)
        @auto_tile_palet_panel.active = true
        @normal_tile_palet_panel.active = false
      end
      
      @normal_tile_palet_panel.evt_left_down do |e|
       @map_panel.using_palet_no = 1
        @normal_tile_palet_panel.on_left_down(e)
        @auto_tile_palet_panel.active = false
        @normal_tile_palet_panel.active = true
      end
      
      
      splitter.split_vertically(panel, editor_panel, 209)
      splitter.minimum_pane_size = 20
      
      self.sizer = Wx::BoxSizer.new(Wx::VERTICAL)
      self.sizer.add(tool_bar, 0, Wx::EXPAND)   
      self.sizer.add(splitter, 1, Wx::EXPAND)
      
      #setup_toolbar
      tool_bar.set_tool_bitmap_size(Wx::Size.new(32,32))
      
      tool_bar.add_tool(1, "Bottom Layer", Texture.load("./icons/bottom_layer").bitmap)
      evt_tool(1) {|event|@map_panel.change_active_layer(0)}
      
      tool_bar.add_tool(2, "Upper Layer", Texture.load("./icons/upper_layer").bitmap)
      evt_tool(2) {|event|@map_panel.change_active_layer(1)}
      
      tool_bar.add_separator
      tool_bar.add_tool(3, "min", Texture.load("./icons/zoom_in").bitmap)
      evt_tool(3) {|event| @map_panel.zoom_in}
      
      tool_bar.add_tool(4, "min", Texture.load("./icons/zoom_out").bitmap)
      evt_tool(4) {|event| @map_panel.zoom_out}
      
      tool_bar.realize
    end
  end
  
  class MainApp < Wx::App
    def on_init
      MainFrame.new("DRPGTools").show
    end
  end
end

DRPGTool::MainApp.new.main_loop
