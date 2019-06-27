// Copyright (c) 2019 Delyan Angelov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

import rand
import time
import gx
import gl
import gg
import glfw
import math

const (
  MaxBricksX = 10
  MaxBricksY = 30
  BrickWidth = 80 // pixels
  BrickHeight = 20 // pixels
	WinWidth = BrickWidth * MaxBricksX
	WinHeight = BrickHeight * MaxBricksY
	TimerPeriod = 17 // ms
)

struct Moves {
  mut:
  left bool
  right bool
}
struct Paddle {
  mut:
  x int
  y int
  speed int
  maxspeed int
  size int // halfsize, from the center till the edges in pixels
  height int
  color gx.Color
  image u32
}

struct Ball {
  mut:
  x int
  y int
  radius int
  dx int
  dy int
  color gx.Color
  image u32
}

struct Brick {
	mut:
	x int
	y int
  color gx.Color
  image u32
}

struct Game {
	mut:
  frames int
  moves Moves
  bricks []Brick
  paddle Paddle
  ball Ball
	// field[y][x] contains the color of the block with (x,y) coordinates
	// "-1" border is to avoid bounds checking.
	// -1 -1 -1 -1
	// -1  0  0 -1
	// -1  0  0 -1
	// -1 -1 -1 -1
  field []array_int
  quit bool
	gg          *gg.GG
}

fn main() {
	glfw.init()
	mut game := &Game{gg: 0}
	game.init_game()
	mut window := glfw.create_window(glfw.WinCfg {
		width: WinWidth
		height: WinHeight
		title: 'V Breakout'
		ptr: game
	})
	window.make_context_current()
	window.onkeydown(key_down)
	gg.init()
	game.gg = gg.new_context(gg.Cfg {
		width: WinWidth
		height: WinHeight
		use_ortho: true
	})
	go game.run()
	go game.print_state()
	for {
    if(game.quit) {
      break
    }
		gl.clear()
		gl.clear_color(0, 0, 0, 255)
		game.draw_scene()
		window.swap_buffers()
		glfw.wait_events()
	}
  println('Have a nice day.')
}

fn (g mut Game) init_game() {
	rand.seed()
	g.init_bricks()
	g.init_field()

//  g.paddle.image = gg.create_image( '/13/home/delian/Work/spytheman_vlang/examples/breakout/paddle.png' )
  g.paddle.color = gx.rgb(0, 127, 0)
  g.paddle.x = WinWidth / 2
  g.paddle.size = 40
  g.paddle.height = 215
  g.paddle.maxspeed = 5
  g.paddle.y = WinHeight - g.paddle.height
  
  g.ball.color = gx.rgb(255, 255, 0)
  g.ball.dx = 3
  g.ball.dy = 3
  g.ball.radius = 12
//  g.ball.image = gg.create_image( '/13/home/delian/Work/spytheman_vlang/examples/breakout/ball.png' )
  
  g.quit = false
}

fn (g mut Game) init_bricks() {
  todo('init_bricks')
}

fn (g mut Game) init_field() {
	g.field = []array_int
	// Generate the field, fill it with 0's, add -1's on each edge
	for i := 0; i < MaxBricksY + 2; i++ {
		mut row := [0; MaxBricksX + 2]
		row[0] = - 1
		row[MaxBricksX + 1] = - 1
		g.field << row
	}
	mut first_row := g.field[0]
	mut last_row := g.field[MaxBricksY + 1]
	for j := 0; j < MaxBricksX + 2; j++ {
		first_row[j] = - 1
		last_row[j] = - 1
	}
}

fn (g mut Game) run() {
	for {
    g.frames++    
		g.move_paddle()
		g.move_ball()
		g.delete_broken_bricks()
		glfw.post_empty_event() // force window redraw
    if(g.quit) {
      break
    }
		time.sleep_ms(TimerPeriod)
	}
}

fn (g mut Game) move_paddle() {
    g.paddle.speed = 0
		if g.moves.left {
        g.paddle.speed = - g.paddle.maxspeed
    }
		if g.moves.right {
        g.paddle.speed =   g.paddle.maxspeed
    }
    g.paddle.x = g.paddle.x + g.paddle.speed
    if g.paddle.x - g.paddle.size < 0 {
       g.paddle.x = g.paddle.size
    }
    if g.paddle.x + g.paddle.size > WinWidth {
       g.paddle.x = WinWidth - g.paddle.size
    }    
}
fn (g mut Game) move_ball() {
   g.ball.x += g.ball.dx
   g.ball.y += g.ball.dy
   if g.ball.x + g.ball.radius > WinWidth && g.ball.dx > 0 {
     g.ball.x = WinWidth - g.ball.radius
     g.ball.dx *= -1
   }
   if g.ball.x - g.ball.radius < 0 && g.ball.dx < 0 {
     g.ball.x = g.ball.radius
     g.ball.dx *= -1
   }
   if g.ball.y + g.ball.radius > WinHeight && g.ball.dy > 0 {
     g.ball.y = WinHeight - g.ball.radius
     g.ball.dy *= -1
   }
   if g.ball.y - g.ball.radius < 0 && g.ball.dy < 0 {
     g.ball.y = g.ball.radius
     g.ball.dy *= -1
   }
   //g.ball.y += rand.next(4) - 2
   //g.ball.x += rand.next(4) - 2
}

fn (g mut Game) delete_broken_bricks() {
//  todo('delete_broken_bricks')
}

fn (g &Game) print_state() {
  mut old_frames := g.frames
  mut fps = 0
  for {
    if(g.quit){
       break
    }
    fps = g.frames - old_frames
    old_frames = g.frames
    println(' frame: $g.frames | fps: $fps | game.ball: $g.ball.x $g.ball.y | game.paddle: $g.paddle.x $g.paddle.y')
    time.sleep_ms( 1000 )
  }
}

fn (g &Game) draw_paddle() {
  g.gg.draw_rect( g.paddle.x - g.paddle.size, g.paddle.y, 2*g.paddle.size, g.paddle.height, g.paddle.color )
}

fn (g &Game) draw_ball() {
  g.gg.draw_rect( g.ball.x-g.ball.radius, g.ball.y-g.ball.radius, 2*g.ball.radius, 2*g.ball.radius, g.ball.color )
}

fn (g &Game) draw_brick(i int, j int) {
  todo('draw_brick $i $j')
}
fn (g &Game) draw_bricks() {
	for i := 1; i < MaxBricksY + 1; i++ {
		for j := 1; j < MaxBricksX + 1; j++ {
			f := g.field[i]
			if f[j] > 0 {
				g.draw_brick(i, j)
			}
		}
	}
}

fn (g &Game) draw_scene() {
	g.draw_bricks()
  g.draw_paddle()
  g.draw_ball()
}

const (
  KEY_UP = 0
  KEY_DOWN = 1
  KEY_REPEAT = 2
)
fn key_down(wnd voidptr, key int, code int, action, mods int) {
  if  action == KEY_DOWN {
  	mut g := &Game(glfw.get_window_user_pointer(wnd))
	  switch key {
    	case glfw.KEY_ESCAPE:
        g.quit = true
  	  case glfw.KeyLeft:
        g.start_moving_paddle(true, false)
    	case glfw.KeyRight:
        g.start_moving_paddle(false, true)
    	case glfw.KeyUp:
        g.start_moving_paddle(false, false)
    }  
    //println('key: $key | action: $action | mods: $mods')
  }
}

fn todo (s string) {
  println('TODO: $s')
}

fn (g &Game) start_moving_paddle(le bool, ri bool) {
    g.moves.right = ri
    g.moves.left  = le
}
