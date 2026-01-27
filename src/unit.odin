package main

import rl "vendor:raylib"

Unit :: struct {
	pos:            rl.Vector2,
	velocity:       rl.Vector2,
	height:         f32,
	velocity_z:     f32,
	is_grounded:    bool,
	visual_pos:     rl.Vector2,
	grid_pos:       Point,
	current_height: f32,
	path:           [dynamic]Point,
	move_timer:     f32,
	input_dir:      rl.Vector2,
}

init_bob :: proc() -> Unit {
	return Unit {
		pos = {10, 10},
		height = 0,
		is_grounded = false,
		velocity_z = 0.0,
		input_dir = {0, 0},
	}
}
