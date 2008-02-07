#
# logo-model.rb
#    methods for drawing GtkGLExt logo models.
#
#  Copyright (c) 2004 Masao Mutoh
#
# You can redistribute it and/or modify it under the terms of
# the GNU GPL.
#
# Original C version was written by Naofumi Yasufuku
# which is licensed under the terms of the GNU
# General Public License (GNU GPL).
#

require 'trackball'

def logo_draw_cube
  n = [
    [ -1.0,  0.0,  0.0 ],
    [  0.0,  1.0,  0.0 ],
    [  1.0,  0.0,  0.0 ],
    [  0.0, -1.0,  0.0 ],
    [  0.0,  0.0,  1.0 ],
    [  0.0,  0.0, -1.0 ]
  ]
  faces = [
    [ 0, 1, 2, 3 ],
    [ 3, 2, 6, 7 ],
    [ 7, 6, 5, 4 ],
    [ 4, 5, 1, 0 ],
    [ 5, 6, 2, 1 ],
    [ 7, 4, 0, 3 ]
  ]
  v = [
    [ -5.5, -5.5, -5.5 ],
    [ -5.5, -5.5,  5.5 ],
    [ -5.5,  5.5,  5.5 ],
    [ -5.5,  5.5, -5.5 ],
    [  5.5, -5.5, -5.5 ],
    [  5.5, -5.5,  5.5 ],
    [  5.5,  5.5,  5.5 ],
    [  5.5,  5.5, -5.5 ]
  ]

  5.downto(0) do |i|
    GL.Begin(GL::QUADS)
    GL.Normal(*n[i])
    0.upto(3) do |j|
      GL.Vertex(*v[faces[i][j]])
    end
    GL.End
  end
end

def logo_draw_plane(n, v)
  GL.Begin(GL::QUADS)
  GL.Normal(n[0], n[1], n[2])
  0.upto(3) do |i|
    GL.Vertex(v[i][0], v[i][1], v[i][2])
  end
  GL.End
end

def logo_draw_g_plane
  n = [0.0, 1.0, 0.0]
  v = [
    [ -5.0, 6.5, -5.0 ],
    [ -5.0, 6.5,  5.0 ],
    [  5.0, 6.5,  5.0 ],
    [  5.0, 6.5, -5.0 ]
  ]
  logo_draw_plane(n, v)
end

def logo_draw_t_plane
  n = [0.0, 0.0, 1.0]
  v = [
    [ -5.0,  5.0, 6.5 ],
    [ -5.0, -5.0, 6.5 ],
    [  5.0, -5.0, 6.5 ],
    [  5.0,  5.0, 6.5 ]
  ]
  logo_draw_plane(n, v)
end

def logo_draw_k_plane
  n = [1.0, 0.0, 0.0]
  v = [
    [ 6.5,  5.0,  5.0 ],
    [ 6.5, -5.0,  5.0 ],
    [ 6.5, -5.0, -5.0 ],
    [ 6.5,  5.0, -5.0 ]
  ]
  logo_draw_plane(n, v)
end

def logo_draw_triangle(size, v)
  (0...size).each do |i|
    v0, v1, v2 = v[i][2], v[i][1], v[i][0]
    w0 = v1.vsub(v0)
    w1 = v2.vsub(v1)
    n = w0.vcross(w1)
    m = n.vlength
    if (m > 0.0)
      m = 1.0 / Math.sqrt(m)
      n = n.vscale(m)
    end

    GL.Begin(GL::TRIANGLES)
    GL.Normal(*n)
    GL.Vertex(*v0)
    GL.Vertex(*v1)
    GL.Vertex(*v2)
    GL.End
  end
end

# AC3D triangle data
require 'logo-g'
def logo_draw_g
  logo_draw_triangle(LOGO_G_V_SIZE, $logo_g_v)
end

# AC3D triangle data
require 'logo-t'
def logo_draw_t
  logo_draw_triangle(LOGO_T_V_SIZE, $logo_t_v)
end
# AC3D triangle data
require 'logo-k'
def logo_draw_k
  logo_draw_triangle(LOGO_K_V_SIZE, $logo_k_v)
end
