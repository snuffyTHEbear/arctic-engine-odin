package main

import rl "vendor:raylib"
WaveType :: enum{
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

ColourPair :: struct{
    low: rl.Color,
    high: rl.Color,
}

WaveControls::struct{
    active_type: WaveType,
    speed: f32,
    frequency: f32,
    amplitude: f32,
    steps: f32,
    palette_idx: int,
}

init_controls :: proc() -> WaveControls {
    return WaveControls {
        active_type = .FLAT,
        speed = 2.0,
        frequency = 0.2,
        amplitude = 10.0,
        steps = 15.0,
        palette_idx = 0,
    }
}

update_wave_controls :: proc(controls: ^WaveControls, dt: f32){
    if rl.IsKeyPressed(.TAB){
        controls.active_type = WaveType((int(controls.active_type) + 1) % len(WaveType))
    }

    if rl.IsKeyPressed(.C){
        controls.palette_idx = (controls.palette_idx + 1) % len(THEMES)
    }

    if rl.IsKeyDown(.W) do controls.speed += 5.0 * dt
    if rl.IsKeyDown(.S) do controls.speed -= 5.0 * dt

    if rl.IsKeyDown(.D) do controls.frequency += 1.0 * dt
    if rl.IsKeyDown(.A) do controls.frequency -= 1.0 * dt

    if rl.IsKeyDown(.UP) do controls.amplitude += 10.0 * dt
    if rl.IsKeyDown(.DOWN) do controls.amplitude -= 10.0 * dt

    if rl.IsKeyPressed(.RIGHT){
        controls.steps += 1.0
        if controls.steps == 0.0 do controls.steps = 1.0
    }
    if rl.IsKeyPressed(.LEFT){
        controls.steps -= 1.0
        if controls.steps == 0.0 do controls.steps = -1.0
    }
}