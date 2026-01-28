package main

import rl "vendor:raylib"
WaveType :: enum {
	FLAT,
	DIAGONAL,
	CIRCULAR,
	NOISE,
	SPIRAL,
	INTERFERANCE,
	BOUNCE,
	GLITCH,
	SQUARE,
	SAWTOOTH,
	TRIANGLE,
	STEPPED,
	BINARY_NOISE,
}

ColourPair :: struct {
	low:  rl.Color,
	high: rl.Color,
}

Controls :: struct {
	active_type: WaveType,
	speed:       f32,
	frequency:   f32,
	amplitude:   f32,
	steps:       f32,
	palette_idx: int,
	paused:      bool,
}

init_controls :: proc() -> Controls {
	return Controls {
		active_type = .FLAT,
		speed = 2.0,
		frequency = 0.2,
		amplitude = 10.0,
		steps = 15.0,
		palette_idx = 0,
		paused = false,
	}
}

update_controls :: proc(controls: ^Controls, dt: f32, bob: ^Unit) {
	if rl.IsKeyPressed(.TAB) {
		controls.active_type = WaveType((int(controls.active_type) + 1) % len(WaveType))
	}

	if rl.IsKeyPressed(.C) {
		controls.palette_idx = (controls.palette_idx + 1) % len(THEMES)
	}

	if rl.IsKeyPressed(.PAUSE) {
		//Pause rendering
		controls.paused = !controls.paused
	}

	if rl.IsKeyDown(.KP_3) do controls.speed += 5.0 * dt
	if rl.IsKeyDown(.KP_1) do controls.speed -= 5.0 * dt

	if rl.IsKeyDown(.KP_9) do controls.frequency += 1.0 * dt
	if rl.IsKeyDown(.KP_7) do controls.frequency -= 1.0 * dt

	if rl.IsKeyDown(.UP) do controls.amplitude += 10.0 * dt
	if rl.IsKeyDown(.DOWN) do controls.amplitude -= 10.0 * dt

	if rl.IsKeyPressed(.KP_ADD) {
		controls.steps += 1.0
		if controls.steps == 0.0 do controls.steps = 1.0
	}
	if rl.IsKeyPressed(.KP_SUBTRACT) {
		controls.steps -= 1.0
		if controls.steps == 0.0 do controls.steps = -1.0
	}

	if rl.IsKeyDown(.W) do bob.input_dir.y -= 1.0
	if rl.IsKeyDown(.S) do bob.input_dir.y += 1.0
	if rl.IsKeyDown(.A) do bob.input_dir.x -= 1.0
	if rl.IsKeyDown(.D) do bob.input_dir.x += 1.0

	if rl.Vector2Length(bob.input_dir) > 0.0 {
		bob.input_dir = rl.Vector2Normalize(bob.input_dir)
	}

	if rl.IsKeyPressed(.SPACE) {
		if bob.is_grounded {
			bob.velocity_z = JUMP_FORCE
			bob.is_grounded = false
			bob.height += 0.5
		}
	}
}
