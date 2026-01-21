package main

import "core:math/rand"
import "core:math/linalg"
import "core:fmt"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

//Constants for performance
SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720
TARGET_FPS :: 144 // High refresh rate can be altered for displays that support it
MAP_SIZE_X :: 50
MAP_SIZE_Y :: 20
MAP_SIZE :: MAP_SIZE_X * MAP_SIZE_Y

TILE_SIZE :: 64
TILE_OFFSET :: TILE_SIZE / 2

SHADER_VS :: "./assets/shaders/iso_depth.vs"
SHADER_FS :: "./assets/shaders/iso_depth.fs"

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

    bob := Unit{
        grid_pos = {1, 1},
        visual_pos = {start_pos.x, start_pos.y},
    }

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

    for y in 0..<world.height{
        for x in 0..<world.width{
            idx := get_tile_index(&world, x, y)
            world.tile_heights[idx] = rand.float32() * 100.0
            world.tile_ids[idx] = .WHITE
        }
    }
    fmt.println("Engine started Map Initialized")

    for !rl.WindowShouldClose()
    {
        dt := rl.GetFrameTime()
        update_camera(&rts_cam)

        mouse_screen_pos := rl.GetMousePosition()
        mouse_world := rl.GetScreenToWorld2D(mouse_screen_pos, rts_cam.rl_camera)
        hover_x, hover_y := screen_to_iso(mouse_world)
// Input
        if rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonPressed(.RIGHT)
        {
            gx, gy := hover_x, hover_y
            if gx >= 0 && gx < world.width && gy >= 0 && gy < world.height
            {
                idx := get_tile_index(&world, gx, gy)
                fmt.println("Clicked Tile: ", gx, ", ", gy, " Index: ", idx)
                
                if rl.IsMouseButtonPressed(.LEFT)
                {
                    //Add a height cap for when it reaches e.g. 100 it resets to 0
                    world.tile_heights[idx] += 10.0
                    if world.tile_heights[idx] > 100.0
                    {
                        world.tile_heights[idx] = 0.0
                    }
                }
                else if rl.IsMouseButtonPressed(.RIGHT)
                {
                    if len(bob.path) > 0 {
                        delete(bob.path)
                    }
                    
                    target := Point{gx, gy}
                    bob.path = find_path(&pathfinder, &world, bob.grid_pos, target)

                    if bob.path == nil{
                        fmt.println("No path found!")
                    } else {
                        fmt.println("Path found with ", len(bob.path), " nodes.")
                    }
                }
            }
        }
// Movement
        if len(bob.path) > 0{
            next_step := bob.path[0]

            if next_step == bob.grid_pos{
                ordered_remove(&bob.path, 0)
            }
            else
            {
                target_world := iso_to_screen(next_step.x, next_step.y)
                next_idx := get_tile_index(&world, next_step.x, next_step.y)
                next_height := world.tile_heights[next_idx]
                target_vis := rl.Vector2{target_world.x, target_world.y - next_height}

                dist := rl.Vector2Distance(bob.visual_pos, target_vis)
                //move_speed := 200.0 // Units per second
                if dist < 2.0{
                    bob.grid_pos = next_step // snap
                    bob.current_height = next_height
                }
                else
                {
                    bob.visual_pos = linalg.lerp(bob.visual_pos, target_vis, 30.0 * dt)
                    bob.current_height = linalg.lerp(bob.current_height, next_height, 30.0 * dt)
                }
            }
        }
// Drawing
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        //rlgl.ClearColor(1,1,1,1)
        //rlgl.Clear(rlgl.COLOR_BUFFER_BIT | rlgl.DEPTH_BUFFER_BIT)
        rlgl.ClearScreenBuffers()
        //rl.rlClearScreenBuffers()

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

                    type := world.tile_ids[idx]
                    rect := atlas.sprites[type]

                    pos := iso_to_screen(x, y)

                    visual_pos := rl.Vector2{pos.x - TILE_OFFSET, pos.y - TILE_OFFSET - h}

                    //source_rect := rl.Rectangle{0, 0, TILE_SIZE, TILE_SIZE}
                    
                    s_idx := get_tile_index(&world, x, y+1)
                    s_h := f32(-10.0)
                    if s_idx != -1 do s_h = world.tile_heights[s_idx]

                    if h > s_h
                    {
                        wall_colour := rl.Color{200, 200, 200, 255}
                        draw_wall(atlas.texture, rect, pos, h, s_h, WALL_TYPES.SOUTH_FACE, wall_colour)
                    }

                    e_idx := get_tile_index(&world, x+1, y)
                    e_h := f32(-10.0)
                    if e_idx != -1 do e_h = world.tile_heights[e_idx]

                    if h > e_h
                    {
                        wall_colour := rl.Color{150, 150, 150, 255}
                        draw_wall(atlas.texture, rect, pos, h, e_h, WALL_TYPES.EAST_FACE, wall_colour)
                    }

                    if h > 0.0
                    {
                        // rlgl.DisableDepthMask()
                        // shadow_visual_pos := rl.Vector2{pos.x - TILE_OFFSET, pos.y - TILE_OFFSET}
                        // draw_tile(atlas.texture, rect, shadow_visual_pos, pos.y - 1.0, rl.Color{0,0,0,60})
                        // rlgl.EnableDepthMask()
                    }
                    draw_tile(atlas.texture, rect, visual_pos, pos.y, rl.WHITE)                    
                }
            }
            //When bob moves lift him?
            //Draw Bob
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

        rl.DrawText(rl.TextFormat("Hover: %i, %i", i32(hover_x), i32(hover_y)), 10, 60, 20, rl.ORANGE)
        rl.DrawText("Right/Middle Click to Pan, Wheel to zoom.", 10, 80, 20, rl.DARKPURPLE)
        rl.DrawText(rl.TextFormat("Tiles Drawn: %i", (max_x - min_x) * (max_y - min_y)), 10, 100, 20, rl.YELLOW)

        rl.DrawFPS(SCREEN_WIDTH - 100, 10)

        rl.EndDrawing()
    }
}