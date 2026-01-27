package main

//import "core:math/rand"
//import "core:math/linalg"
import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

SCREEN_WIDTH :: 1920
SCREEN_HEIGHT :: 1080
TARGET_FPS :: 144
MAP_SIZE_X :: 30
MAP_SIZE_Y :: 30
MAP_SIZE :: MAP_SIZE_X * MAP_SIZE_Y

TILE_SIZE :: 64
TILE_OFFSET :: TILE_SIZE / 2

SHADER_VS :: "./assets/shaders/iso_depth.vs"
SHADER_FS :: "./assets/shaders/iso_depth.fs"

BlockIndex :: struct
{
    curr_idx: int,
    prev_idx: int,
    next_idx: int,
}

Unit :: struct 
{
    grid_pos: Point,
    visual_pos: rl.Vector2,
    current_height: f32,
    path: [dynamic]Point,
    move_timer: f32,
}

main :: proc()
{
    
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Arctic-Engine")
    
    rl.SetTargetFPS(TARGET_FPS)

    defer rl.CloseWindow()

    rts_cam := init_camera(SCREEN_WIDTH, SCREEN_HEIGHT)

    shader := rl.LoadShader(SHADER_VS, SHADER_FS)
    defer rl.UnloadShader(shader)

    pathfinder := init_pathfinder(MAP_SIZE_X, MAP_SIZE_Y)
    defer destroy_pathfinder(&pathfinder)

    start_pos := iso_to_screen(0,0)

    controls := init_controls()

    bob := Unit{
        grid_pos = {1, 1},
        visual_pos = {start_pos.x, start_pos.y},
    }

    // hovered_block := BlockIndex{
    //     curr_idx = -1,
    //     prev_idx = 0,
    //     next_idx = 0,
    // }

    map_height_loc := rl.GetShaderLocation(shader, "mapHeight")
    if map_height_loc == -1
    {
        fmt.println("Failed to get mapHeight uniform location in shader")
    }
    map_h_val : f32 = MAP_SIZE * TILE_SIZE + 2000.0
    rl.SetShaderValue(shader, map_height_loc, &map_h_val, .FLOAT)

    atlas := init_atlas()
    defer destroy_atlas(&atlas)
    
    world := init_map(MAP_SIZE_X, MAP_SIZE_Y)
    defer destroy_map(&world)

    // for y in 0..<world.height{
    //     for x in 0..<world.width{
    //         idx := get_tile_index(&world, x, y)
    //         world.tile_heights[idx] = rand.float32() * 100.0
    //         world.tile_ids[idx] = .WHITE
    //     }
    // }
    fmt.println("Engine started, Map Initialized")

    for !rl.WindowShouldClose()
    {
        dt := rl.GetFrameTime()
        time := f32(rl.GetTime())
        update_camera(&rts_cam)
        update_wave_controls(&controls, dt)

        

        mouse_screen_pos := rl.GetMousePosition()
        mouse_world := rl.GetScreenToWorld2D(mouse_screen_pos, rts_cam.rl_camera)
        hover_x, hover_y := screen_to_iso(mouse_world)

        // if hover_x >= 0 && hover_x < world.width && hover_y >= 0 && hover_y < world.height
        // {
        //     idx := get_tile_index(&world, hover_x, hover_y)    
        //     if hovered_block.curr_idx != idx{
        //         hovered_block.prev_idx = hovered_block.curr_idx
        //         hovered_block.curr_idx = idx
        //     } 
        // }

        for y in 0..<world.height{
            for x in 0..<world.width{
                cx := f32(world.width) / 2.0
                cy := f32(world.height) / 2.0
                dx := f32(x) - cx
                dy := f32(y) - cy
                dist := math.sqrt_f32(dx * dx + dy * dy)

                idx := get_tile_index(&world, x, y)

                offset := f32(0.0)

                switch controls.active_type{
                    // case .NONE:
                    //     offset = 0.0
                    case .FLAT:
                        offset = controls.amplitude
                    case .DIAGONAL:
                        dist = f32 (x + y)
                        offset = math.sin_f32(time * controls.speed + dist * controls.frequency)
                    case .CIRCULAR:
                        
                        offset = math.sin_f32(time * controls.speed - dist * controls.frequency)
                    case .NOISE:
                        offset = math.sin_f32(time * 5.0 + f32(idx))
                    case .SPIRAL:
                        angle := math.atan2_f32(dy, dx)
                        offset = math.sin_f32(time * controls.speed - dist * controls.frequency + angle * 5.0)
                    case .INTERFERANCE:
                        w1 := math.sin_f32(time * controls.speed + f32(x) * controls.frequency)
                        w2 := math.sin_f32(time * controls.speed + f32(y) * controls.frequency)
                        offset = (w1 + w2) * 5.0
                    case .BOUNCE:
                        raw_sine := math.sin_f32(time * controls.speed + dist * controls.frequency)
                        offset = math.abs(raw_sine)
                    case .GLITCH:
                        val := math.tan_f32(time * 5.0 + dist * 0.1)
                        offset = rl.Clamp(val, -1.0, 1.0)
                    case .SQUARE:
                        raw_val := math.sin_f32(time * controls.speed + dist * controls.frequency)
                        if raw_val > 0{
                            offset = 1.0
                        } else {
                            offset = -1.0
                        }
                    case .SAWTOOTH:
                        input_val := (time * controls.speed + dist * controls.frequency)
                        offset = math.mod_f32(input_val, 1.0) * 2.0 - 1.0
                    case .TRIANGLE:
                        input_val := (time * controls.speed + dist * controls.frequency) * 0.5
                        offset = 2.0 * math.abs(2.0 * (input_val - math.floor_f32(input_val + 0.5))) - 1.0
                    case .STEPPED:
                        raw_sine := math.sin_f32(time * controls.speed + dist * controls.frequency)
                        offset = math.floor_f32(raw_sine * controls.steps) / controls.steps
                    case .BINARY_NOISE:
                        t_int := int(time * 10.0)
                        val := (x * y * t_int) & 1
                        offset = f32(val * 2 - 1)
                }
                world.tile_heights[idx] = offset * controls.amplitude//BASE_HEIGHT + (offset * WAVE_AMP)
            }
        }

// Input
        // if rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT)
        // {
        //     gx, gy := hover_x, hover_y
        //     if gx >= 0 && gx < world.width && gy >= 0 && gy < world.height
        //     {
        //         idx := get_tile_index(&world, gx, gy)
        //         fmt.println("Clicked Tile: ", gx, ", ", gy, " Index: ", idx)
                
        //         if rl.IsMouseButtonPressed(.LEFT)
        //         {
        //             //Add a height cap for when it reaches e.g. 100 it resets to 0
        //             world.tile_heights[idx] += 10.0
        //             if world.tile_heights[idx] > 100.0
        //             {
        //                 world.tile_heights[idx] = 0.0
        //             }
        //         }
        //         else if rl.IsMouseButtonPressed(.RIGHT)
        //         {
        //             if len(bob.path) > 0 {
        //                 delete(bob.path)
        //             }
                    
        //             target := Point{gx, gy}
        //             bob.path = find_path(&pathfinder, &world, bob.grid_pos, target)

        //             if bob.path == nil{
        //                 fmt.println("No path found!")
        //             } else {
        //                 fmt.println("Path found with ", len(bob.path), " nodes.")
        //             }
        //         }
        //     }
        // }

        if rl.IsKeyPressed(.F5)
        {
            save_map(&world, "level_data.bin")
        }

        if rl.IsKeyPressed(.F6)
        {
            destroy_map(&world)
            world = load_map("level_data.bin")

            new_pixel_height := f32(world.height * 32) + 2000.0
            rl.SetShaderValue(shader, map_height_loc, &new_pixel_height, .FLOAT)

            if(bob.grid_pos.x >= world.width || bob.grid_pos.y >= world.height)
            {
                bob.grid_pos = Point{0,0}
                bob.visual_pos = iso_to_screen(0,0)
                bob.current_height = world.tile_heights[0]
                clear(&bob.path)
            }
        }
// Movement
        // if len(bob.path) > 0{
        //     next_step := bob.path[0]

        //     if next_step == bob.grid_pos{
        //         ordered_remove(&bob.path, 0)
        //     }
        //     else
        //     {
        //         target_world := iso_to_screen(next_step.x, next_step.y)
        //         next_idx := get_tile_index(&world, next_step.x, next_step.y)
        //         next_height := world.tile_heights[next_idx]
        //         target_vis := rl.Vector2{target_world.x, target_world.y - next_height}

        //         dist := rl.Vector2Distance(bob.visual_pos, target_vis)
        //         //move_speed := 200.0 // Units per second
        //         if dist < 2.0{
        //             bob.grid_pos = next_step // snap
        //             bob.current_height = next_height
        //         }
        //         else
        //         {
        //             bob.visual_pos = linalg.lerp(bob.visual_pos, target_vis, 30.0 * dt)
        //             bob.current_height = linalg.lerp(bob.current_height, next_height, 30.0 * dt)
        //         }
        //     }
        // }
// Drawing
        rl.BeginDrawing()
        rl.ClearBackground(rl.BROWN)
        //rlgl.ClearColor(1,1,1,1)
        //rlgl.Clear(rlgl.COLOR_BUFFER_BIT | rlgl.DEPTH_BUFFER_BIT)
        rlgl.ClearScreenBuffers()
        //rl.rlClearScreenBuffers()
        current_theme := THEMES[controls.palette_idx]

        rl.BeginMode2D(rts_cam.rl_camera)
            rlgl.EnableDepthTest()
            rl.BeginShaderMode(shader)
            
            min_x, min_y, max_x, max_y := get_visible_tiles(rts_cam.rl_camera, world.width, world.height)

            for y := max_y; y >= min_y; y -= 1
            {
                for x:= max_x; x >= min_x; x -= 1
                {
                    idx := get_tile_index(&world, x, y)
                    h   := world.tile_heights[idx]

                    min_h := -controls.amplitude
                    max_h := controls.amplitude
                    range := max_h - min_h

                    if range < 1.0 do range = 1.0

                    t := (h - min_h) / range
                    t = rl.Clamp(t, 0.0, 1.0)
                    t = math.floor_f32(t * controls.steps) / controls.steps

                    // COL_LOW :: PASTEL.TeaGreen//rl.Color{20, 40, 90, 255}
                    // COL_HIGH :: PASTEL.Orange//rl.Color{200, 240, 255, 255}

                    tile_colour := rl.ColorLerp(current_theme.low, current_theme.high, t)
                    
                    type := world.tile_ids[idx]
                    rect := atlas.sprites[type]

                    pos := iso_to_screen(x, y)

                    //wobble_x := math.sin_f32(time * 5.0 + f32(y) * 0.5) * 4.0
                    //wobble_y := math.sin_f32(time * 5.0 + f32(x) * 0.5) * 4.0
                    
                    visual_pos := rl.Vector2{pos.x - TILE_OFFSET, pos.y - TILE_OFFSET - h}
                    // visual_pos := rl.Vector2{
                    //     pos.x - TILE_OFFSET + wobble_x,
                    //     pos.y - TILE_OFFSET - h + wobble_y,
                    // }
                    //source_rect := rl.Rectangle{0, 0, TILE_SIZE, TILE_SIZE}
                    //color := rl.WHITE
                    

                    s_idx := get_tile_index(&world, x, y+1)
                    s_h := f32(-10.0)
                    if s_idx != -1 do s_h = world.tile_heights[s_idx]

                    if h > s_h
                    {
                        wall_colour := rl.ColorBrightness(tile_colour, -0.2)//rl.Color{200, 200, 200, 255}
                        draw_wall(atlas.texture, rect, pos, h, s_h, WALL_TYPES.SOUTH_FACE, wall_colour)
                    }

                    e_idx := get_tile_index(&world, x+1, y)
                    e_h := f32(-10.0)
                    if e_idx != -1 do e_h = world.tile_heights[e_idx]

                    if h > e_h
                    {
                        wall_colour := rl.ColorBrightness(tile_colour, -0.4)//rl.Color{150, 150, 150, 255}
                        draw_wall(atlas.texture, rect, pos, h, e_h, WALL_TYPES.EAST_FACE, wall_colour)
                    }

                    draw_tile(atlas.texture, rect, visual_pos, pos.y, tile_colour)                    
                }
            }
            //When bob moves lift him?
            
            bob_sort_y := bob.visual_pos.y + bob.current_height// + 1.0
            bob_sort_y += 1.0
            bob_rect := atlas.sprites[TileType.BOB]
            //rl.Rectangle{0, 0, TILE_SIZE, TILE_SIZE}
            draw_tile(atlas.texture, bob_rect, {bob.visual_pos.x - TILE_OFFSET, bob.visual_pos.y - TILE_OFFSET}, bob_sort_y, rl.WHITE)
            rl.EndShaderMode()
            
            //DEBUG LINES
            if len(bob.path) > 0{
                rlgl.DisableDepthTest()
                for i in 0..<len(bob.path)-1{

                    p1 := bob.path[i]
                    p2 := bob.path[i+1]

                    pos1 := iso_to_screen(p1.x, p1.y)
                    pos2 := iso_to_screen(p2.x, p2.y)

                    rl.DrawLineV({pos1.x, pos1.y - 10}, {pos2.x, pos2.y - 10}, rl.GREEN)
                }
                rlgl.EnableDepthTest()
            }
        
            rlgl.DisableDepthTest()
        rl.EndMode2D()

        // rl.DrawRectangle(5, 5,      450,    250, rl.Fade(rl.BLACK, 0.7))
        // rl.DrawRectangleLines(5,5,  450,    250,rl.BEIGE)
        start_y :: 15
        step_y :: 25

        rl.DrawText(rl.TextFormat("MODE (Tab): %v",         controls.active_type),          15, start_y, 20, rl.GREEN)
        rl.DrawText(rl.TextFormat("Speed (W/S): %.2f",      controls.speed),                15, start_y + step_y * 1, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Freq (A/D): %.2f",       controls.frequency),            15, start_y + step_y * 2, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Amp (Up/Dn): %.2f",      controls.amplitude),            15, start_y + step_y * 3, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Hover: %i, %i",          i32(hover_x), i32(hover_y)),    15, start_y + step_y * 4, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Right/Middle Click to Pan, Wheel to zoom."),             15, start_y + step_y * 5, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Tiles Drawn: %i",    (max_x - min_x) * (max_y - min_y)), 15, start_y + step_y * 6, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Steps (Left/Right): %.2f", controls.steps), 15, start_y + step_y * 7, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Theme (C): %v", current_theme.name), 15, start_y + step_y * 8, 20, rl.WHITE)
        rl.DrawFPS(SCREEN_WIDTH - 100, 10)

        rl.EndDrawing()
    }
    
}