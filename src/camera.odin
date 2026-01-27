package main

import rl "vendor:raylib"
import "core:math"

RTSCamera :: struct
{
    rl_camera:      rl.Camera2D,
    zoom_target:    f32,
    is_dragging:     bool,
    drag_origin:    rl.Vector2
}

init_camera :: proc(screen_w, screen_h: f32) ->RTSCamera
{
    return RTSCamera{
        rl_camera = rl.Camera2D{
            offset = {screen_w / 2, screen_h / 2},
            target = {0,0},
            zoom = 1.0,
        },
        zoom_target = 1.0,
    }
}

update_camera :: proc(c: ^RTSCamera){
    dt := rl.GetFrameTime()

    wheel := rl.GetMouseWheelMove()
    if wheel != 0
    {
        mouse_world_pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), c.rl_camera)
        
        c.rl_camera.offset = rl.GetMousePosition()

        c.rl_camera.target = mouse_world_pos

        zoom_speed :: 0.1
        c.zoom_target += wheel * zoom_speed

        if c.zoom_target < 0.1 do c.zoom_target = 0.1
        if c.zoom_target > 3.0 do c.zoom_target = 3.0
    }

    c.rl_camera.zoom = math.lerp(c.rl_camera.zoom, c.zoom_target, 10.0 * dt)

    if rl.IsMouseButtonPressed(.MIDDLE) || rl.IsMouseButtonPressed(.RIGHT)
    {
        c.is_dragging = true
        c.drag_origin = rl.GetScreenToWorld2D(rl.GetMousePosition(), c.rl_camera)
    }

    if rl.IsMouseButtonReleased(.MIDDLE) || rl.IsMouseButtonReleased(.RIGHT)
    {
        c.is_dragging = false
    }

    if c.is_dragging
    {
        mouse_current := rl.GetScreenToWorld2D(rl.GetMousePosition(), c.rl_camera)
        delta := c.drag_origin - mouse_current

        c.rl_camera.target += delta
    }

    //pan_speed := 500.0 * dt / c.rl_camera.zoom

    // if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do c.rl_camera.target.y -= pan_speed
    // if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do c.rl_camera.target.y += pan_speed
    // if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do c.rl_camera.target.x -= pan_speed
    // if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do c.rl_camera.target.x += pan_speed
}

