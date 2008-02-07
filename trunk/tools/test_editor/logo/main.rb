#!/usr/bin/env ruby
#
# Ruby/GtkGLExt logo demo
#
# Copyright (c) 2004 Masao Mutoh
#
# You can redistribute it and/or modify it under the terms of
# the GNU GPL.
#
# Original C version was written by Naofumi Yasufuku
# which is licensed under the terms of the GNU
# General Public License (GNU GPL).
#

require 'logo'

class MainWindow < Gtk::Window
  def initialize(animate, rot_count)
    super()
    set_title("logo")

    # Try double-buffered visual
    glconfig = create_glconfig
    examine_gl_config_attrib(glconfig)

    # Get automatically redrawn if any of their children changed allocation.
    set_reallocate_redraws(true) 
    signal_connect("delete_event"){ Gtk.main_quit }
    
    # VBox.
    vbox = Gtk::VBox.new(false, 0)
    add(vbox)
    
    # Drawing area for drawing OpenGL scene.
    @logo = Logo.new(animate, rot_count, glconfig)
    @logo.set_size_request(300, 300)
    vbox.pack_start(@logo, true, true, 0)
    
    signal_connect_after("key_press_event") do |w, event|
      case event.keyval
      when Gdk::Keyval::GDK_a
        @logo.toggle_animation
      when Gdk::Keyval::GDK_i
        @logo.init_logo_view
      when Gdk::Keyval::GDK_Escape
        destroy
        Gtk.main_quit
      end
      true
    end
    
    menu = create_popup_menu
    signal_connect("button_press_event") do |w, event|
      if (event.button == 3)
        menu.popup(nil, nil, event.button, event.time)
        true
      else
        false
      end
    end
    
    # Quit Button
    button = Gtk::Button.new("Quit")
    button.signal_connect("clicked"){ destroy; Gtk.main_quit }
    vbox.pack_start(button, false, false, 0)
  end

  # Creates the popup menu.
  def create_popup_menu
    menu = Gtk::Menu.new
    [["Toggle Animation", Proc.new{@logo.toggle_animation}],
      ["Initialize", Proc.new{@logo.init_logo_view}],
      ["Quit", Proc.new{destroy; Gtk.main_quit}]].each do |name, meth|
      menu_item = Gtk::MenuItem.new(name)
      menu.append(menu_item)
      menu_item.signal_connect("activate"){meth.call}
    end
    menu.show_all
  end
  
  # Configure OpenGL-capable visual.
  def create_glconfig
    # Try double-buffered visual
    glconfig = Gdk::GLConfig.new(Gdk::GLConfig::MODE_RGB|
                                 Gdk::GLConfig::MODE_DEPTH|
                                 Gdk::GLConfig::MODE_DOUBLE)
    
    unless glconfig
      puts "*** Cannot find the double-buffered visual."
      puts "*** Trying single-buffered visual."
      
      # Try single-buffered visual
      glconfig = Gdk::GLConfig.new(Gdk::GL::MODE_RGB|
                                   Gdk::GL::MODE_DEPTH)
      raise  "No appropriate OpenGL-capable visual found." unless glconfig
    end
    glconfig
  end

  def examine_gl_config_attrib(glconfig)
    puts "\nOpenGL visual configurations :\n\n"
    
    [
      :rgba?, :double_buffered?, :stereo?, :has_alpha?, :has_depth_buffer?,
      :has_stencil_buffer?, :has_accum_buffer?
    ].each { |id| puts "glconfig.#{id} = #{glconfig.send(id)}\n" }
    
    puts "\n"

    [
      :USE_GL, :BUFFER_SIZE, :LEVEL, :RGBA, :DOUBLEBUFFER, :STEREO, :AUX_BUFFERS,
      :RED_SIZE, :GREEN_SIZE, :BLUE_SIZE, :ALPHA_SIZE, :DEPTH_SIZE, :STENCIL_SIZE,
      :ACCUM_RED_SIZE, :ACCUM_GREEN_SIZE, :ACCUM_BLUE_SIZE, :ACCUM_ALPHA_SIZE
    ].each do |id|
      val = glconfig.get_attrib(Gdk::GLConfig.const_get(id))
      if val != nil
        puts "Gdk::GLConfig::#{id} = #{val}\n"
      else
        puts "*** Cannot get Gdk::GLConfig::#{id} attribute value\n"
      end
    end
    puts "\n"
  end
  
  def destroy
    @logo.stop
  	super
  end
end

if $0 == __FILE__
  Gtk.init
  Gtk::GL.init

  arg_count = false
  animate = true
  rot_count = 100
  ARGV.each do |argv|
    if (arg_count)
      rot_count = argv.to_i
    elsif argv == "--help" || argv == "-h"
      puts "Usage: ruby logo.rb [--count num] [--no-anim] [--help]\n"
      exit 0
    elsif argv == "--count"
      arg_count = true
    elsif argv == "--no-anim"
      animate = false
    end
  end
  
  puts "\nOpenGL extension version - #{Gdk::GL.query_version.join(".")}\n"

  window = MainWindow.new(animate, rot_count)
  window.show_all
  Gtk.main
end

