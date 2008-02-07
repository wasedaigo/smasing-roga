#
# logo.rb
#    Drawing area for drawing OpenGL scene.
#
#  Copyright (c) 2004 Masao Mutoh
#
# You can redistribute it and/or modify it under the 
# terms of the GNU GPL.
#
# Original C version was written by Naofumi Yasufuku
# which is licensed under the terms of the GNU
# General Public License (GNU GPL).
#

require 'gtkglext'
require 'logo-model'
require 'trackball'

class Logo < Gtk::DrawingArea
  DIG_2_RAD = Math::PI / 180.0
  TIMEOUT_INTERVAL = 10

  VIEW_INIT_AXIS_X = 1.0
  VIEW_INIT_AXIS_Y = 0.0
  VIEW_INIT_AXIS_Z = 0.0
  VIEW_INIT_ANGLE =  20.0
  
  VIEW_SCALE_MAX = 2.0
  VIEW_SCALE_MIN = 0.5
  
  LOGO_CUBE       = 1
  LOGO_G_FORWARD  = 2
  LOGO_G_BACKWARD = 3
  LOGO_T_FORWARD  = 4
  LOGO_T_BACKWARD = 5
  LOGO_K_FORWARD  = 6
  LOGO_K_BACKWARD = 7

  AXIS_x = [1.0, 0.0, 0.0]
  AXIS_y = [0.0, 1.0, 0.0]
  AXIS_z = [0.0, 0.0, 1.0]

  ROT_MODE = [
    [AXIS_x,  1.0],
    [AXIS_y,  1.0],
    [AXIS_x,  1.0],
    [AXIS_z,  1.0],
    [AXIS_x,  1.0],
    [AXIS_y, -1.0],
    [AXIS_x,  1.0],
    [AXIS_z, -1.0]
  ]

  def initialize(animate, rot_count, glconfig)
    super()
    @view_quat  = [0.0, 0.0, 0.0, 1.0]
    @view_scale = 1.0
    @logo_quat  = [0.0, 0.0, 0.0, 1.0]
    @animate = animate

    @rot_count = rot_count
    @mode = 0
    @counter = 0

    @begin_x = 0.0
    @begin_y = 0.0

    @timeout_id = 0

    init_view

    # Set OpenGL-capability to the widget.
    set_gl_capability(glconfig, nil, true, Gdk::GL::RGBA_TYPE)
    add_events(Gdk::Event::BUTTON1_MOTION_MASK|
	       Gdk::Event::BUTTON2_MOTION_MASK|
	       Gdk::Event::BUTTON_PRESS_MASK)

    signal_connect_after("realize"){ realize }
    signal_connect_after("configure_event"){ configure }
    signal_connect_after("expose_event"){ expose }

    signal_connect_after("button_press_event") do |w, event, menu|
      @begin_x = event.x
      @begin_y = event.y
      false
    end

    signal_connect_after("motion_notify_event") do |w, event|
      motion_notify(event)
    end
    
    signal_connect_after("map_event"){ timeout_add if @animate }
    signal_connect_after("unmap_event"){ timeout_remove }
  end

  def init_view
    sine = Math.sin(0.5 * VIEW_INIT_ANGLE * DIG_2_RAD)
    @view_quat  = [VIEW_INIT_AXIS_X * sine, 
      VIEW_INIT_AXIS_Y * sine,
      VIEW_INIT_AXIS_Z * sine,
      Math.cos(0.5 * VIEW_INIT_ANGLE * DIG_2_RAD)]
    @view_scale = 1.0
  end

  def init_logo_view
    @logo_quat  = [0.0, 0.0, 0.0, 1.0]
    init_view
    @mode = 0
    @counter = 0

    unless @animate
      window.invalidate(allocation.to_rect, false)
    end
  end

  def create_logo(forward, backward, back_color, rotate, 
		  draw_plane_proc, draw_proc)
 
   front_color = [0.0, 0.0, 0.0, 1.0] 
    
    # Forward
    GL.NewList(forward, GL::COMPILE)
    GL.Disable(GL::CULL_FACE)
    GL.Material(GL::FRONT, GL::AMBIENT_AND_DIFFUSE, back_color)
    draw_plane_proc.call
    GL.Enable(GL::CULL_FACE)
    
    GL.Material(GL::FRONT, GL::AMBIENT_AND_DIFFUSE, front_color)
    draw_proc.call
    GL.EndList
    
    # Backward 
    GL.NewList(backward, GL::COMPILE)
    GL.PushMatrix
    GL.Rotate(*rotate)
    
    GL.Disable(GL::CULL_FACE)
    GL.Material(GL::FRONT, GL::AMBIENT_AND_DIFFUSE, back_color)
    draw_plane_proc.call
    GL.Enable(GL::CULL_FACE)
    
    GL.Material(GL::FRONT, GL::AMBIENT_AND_DIFFUSE, front_color)
    draw_proc.call
    
    GL.PopMatrix
    GL.EndList
  end

  #realize callback
  def realize
    gl_drawable.gl_begin(gl_context) {
      # *** OpenGL BEGIN ***
      GL.ClearColor(0.5, 0.5, 0.8, 1.0)
      GL.ClearDepth(1.0)

      GL.Lightfv(GL::LIGHT0, GL::POSITION, [0.0, 0.0, 30.0, 0.0])
      GL.Lightfv(GL::LIGHT0, GL::DIFFUSE,  [1.0, 1.0, 1.0, 1.0])
      GL.Lightfv(GL::LIGHT0, GL::SPECULAR, [1.0, 1.0, 1.0, 1.0])
      
      [GL::LIGHTING, GL::LIGHT0, GL::DEPTH_TEST, 
	GL::CULL_FACE, GL::NORMALIZE].each do |v|
	GL.Enable(v)
      end
      
      GL.ShadeModel(GL::SMOOTH)
      GL.Material(GL::FRONT, GL::SPECULAR, [0.5, 0.5, 0.5, 1.0])
      GL.Material(GL::FRONT, GL::SHININESS, [10.0])

      # "G"
      create_logo(LOGO_G_FORWARD, LOGO_G_BACKWARD,
		  [0.0, 0.0, 1.0, 1.0], [180.0, 1.0, 0.0, 0.0],
		  method(:logo_draw_g_plane), method(:logo_draw_g))
      # "T"
      create_logo(LOGO_T_FORWARD, LOGO_T_BACKWARD,
		  [1.0, 0.0, 0.0, 1.0], [180.0, 1.0, 0.0, 0.0],
		  method(:logo_draw_t_plane), method(:logo_draw_t))
      
      # "K"
      create_logo(LOGO_K_FORWARD, LOGO_K_BACKWARD,
		  [0.0, 1.0, 0.0, 1.0], [180.0, 0.0, 0.0, 1.0],
		  method(:logo_draw_k_plane), method(:logo_draw_k))
      

      # Init logo orientation. 
      @logo_quat  = [0.0, 0.0, 0.0, 1.0]
      
      # Init view. 
      init_view
    }  
  end

  def configure
    w = allocation.width
    h = allocation.height

    gl_drawable.gl_begin(gl_context){
      # *** OpenGL BEGIN ***
      GL.Viewport(0, 0, w, h)
      GL.MatrixMode(GL::PROJECTION)
      GL.LoadIdentity
      if (w > h)
	aspect = w.to_f / h.to_f
	GL.Frustum(-aspect, aspect, -1.0, 1.0, 2.0, 60.0)
      else
	aspect = h.to_f / w.to_f;
	GL.Frustum(-1.0, 1.0, -aspect, aspect, 2.0, 60.0)
      end
      GL.MatrixMode(GL::MODELVIEW)
      # *** OpenGL END ***
    }
  end

  def motion_notify(event)
    width = allocation.width.to_f
    height = allocation.height.to_f
    x = event.x.to_f
    y = event.y.to_f
    
    redraw = false
    
    # Rotation.
    if event.state == Gdk::Window::BUTTON1_MASK
      d_quat = TrackBall.trackball((2.0 * @begin_x - width) / width,
				   (height - 2.0 * @begin_y) / height,
				   (2.0 * x - width) / width,
				   (height - 2.0 * y) / height)
      @view_quat = TrackBall.add_quats(d_quat, @view_quat)
      redraw = true
    end
    
    # Scaling
    if event.state == Gdk::Window::BUTTON2_MASK
	@view_scale = @view_scale * (1.0 + (y - @begin_y) / height)
      if (@view_scale > VIEW_SCALE_MAX)
	@view_scale = VIEW_SCALE_MAX
      elsif (@view_scale < VIEW_SCALE_MIN)
	@view_scale = VIEW_SCALE_MIN
      end
      redraw = true
    end
    
    @begin_x = x
    @begin_y = y
    
    if (redraw && ! @animate)
      window.invalidate(allocation.to_rect, false)
    end
    true
  end

  def expose
    if (@animate)
      if (@counter == @rot_count)
	@mode += 1
	@mode = 0 unless ROT_MODE[@mode]
	@counter = 0
      end
      d_quat = ROT_MODE[@mode][0].axis_to_quat(ROT_MODE[@mode][1] * Math::PI / 2.0 / @rot_count)
      @logo_quat = TrackBall.add_quats(d_quat, @logo_quat)
      @counter += 1.0
    end

    gl_drawable.gl_begin(gl_context){
      # *** OpenGL BEGIN ***
      GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
      GL.LoadIdentity

      # View transformation.
      GL.Translate(0.0, 0.0, -30.0)
      GL.Scale(@view_scale, @view_scale, @view_scale)
      GL.MultMatrix(@view_quat.build_rotmatrix)

      # Logo model
      GL.PushMatrix
      GL.MultMatrix(@logo_quat.build_rotmatrix)

      GL.Rotate(90.0, 1.0, 0.0, 0.0)
      [LOGO_CUBE, LOGO_G_FORWARD, LOGO_G_BACKWARD,
	LOGO_T_FORWARD, LOGO_T_BACKWARD, 
	LOGO_K_FORWARD, LOGO_K_BACKWARD].each do |v|
	GL.CallList(v)
      end
      GL.PopMatrix

      # Swap buffers. 
      if gl_drawable.double_buffered?
	gl_drawable.swap_buffers
      else
	GL.Flush
      end
    }
  end

  def timeout_add
    if @timeout_id == 0
      @timeout_id = Gtk.timeout_add(TIMEOUT_INTERVAL) do
	# Invalidate the whole window.
	window.invalidate(allocation.to_rect, false)
	# Update synchronously. 
	window.process_updates(false)
	true
      end
    end
  end

  def timeout_remove
    if @timeout_id != 0
      Gtk.timeout_remove(@timeout_id)
      @timeout_id = 0
    end
  end

  def toggle_animation
    @animate = ! @animate

    if @animate
      timeout_add
    else
      timeout_remove
      window.invalidate(allocation.to_rect, false)
    end
  end
  
  def stop
    # stops the animation
  	toggle_animation if @animate
  end
end
