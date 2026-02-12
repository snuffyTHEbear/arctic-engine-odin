package main

//import "core:math/rand"
//import "core:math/linalg"
import "core"
import "core:fmt"
import "entities"
import "gfx"
import "gfx/utils"
import "states"
import "ui"
import rl "vendor:raylib"
import "world"

SCREEN_WIDTH :: 1920
SCREEN_HEIGHT :: 1080
TARGET_FPS :: 144
MAP_SIZE_X :: 50
MAP_SIZE_Y :: 50
MAP_SIZE :: MAP_SIZE_X * MAP_SIZE_Y

SHADER_VS :: "../assets/shaders/iso_depth.vs"
SHADER_FS :: "../assets/shaders/iso_depth.fs"

Game :: struct {
	state:    states.RunState,
	isomap:   world.IsoMap,
	atlas:    gfx.Atlas,
	controls: states.Controls,
	camera:   entities.RTSCamera,
}

init_game :: proc() -> Game {
	g := Game {
		state    = states.RunState.MENU,
		atlas    = gfx.init_atlas(64),
		controls = states.init_controls(),
		isomap   = world.init_map(MAP_SIZE_X, MAP_SIZE_Y),
		camera   = entities.init_camera(SCREEN_WIDTH, SCREEN_HEIGHT),
	}

	return g
}

destroy_game :: proc(g: ^Game) {
	world.destroy_map(&g.isomap)
	gfx.destroy_atlas(&g.atlas)
}

main :: proc() {

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Arctic-Engine")
	rl.SetTargetFPS(TARGET_FPS)
	defer rl.CloseWindow()

	game := init_game()
	defer destroy_game(&game)

	rts_cam := game.camera //:= init_camera(SCREEN_WIDTH, SCREEN_HEIGHT)

	pathfinder := core.init_pathfinder(MAP_SIZE_X, MAP_SIZE_Y)
	defer core.destroy_pathfinder(&pathfinder)

	controls := game.controls

	shader := gfx.init_shader(SHADER_FS, SHADER_VS, MAP_SIZE, &controls)
	defer rl.UnloadShader(shader)

	//atlas := game.atlas

	iso_world := game.isomap
	fmt.println("Engine started, Map Initialized")

	debugPanel := ui.init_debug_panel()
	defer ui.destroy_debug_panel(&debugPanel)
	states.generate_text_map(&iso_world, "ARCTIC")

	ui.add_variable(&debugPanel, "MODE (Tab)", controls.active_type)
	ui.add_variable(&debugPanel, "Speed (1/3)", controls.speed)
	ui.add_variable(&debugPanel, "Freq (7/9)", controls.frequency)
	ui.add_variable(&debugPanel, "Amp (Up/Dn)", controls.amplitude)
	ui.add_variable(&debugPanel, "Steps (-/+)", controls.steps)
	ui.add_variable(&debugPanel, "Theme (C)", utils.THEMES[controls.palette_idx].name)
	ui.add_variable(&debugPanel, "Paused (Pause)", controls.paused)
	ui.add_variable(&debugPanel, "Tiles Drawn", int(0))
	ui.add_variable(&debugPanel, "Hover", core.Point{0, 0})
	ui.add_variable(&debugPanel, "Right/Middle Click to Pan, Wheel to zoom.", "")
	ui.add_variable(&debugPanel, "State (F2)", controls.state)
	ui.add_variable(&debugPanel, "Tile Size (F5/F6)", controls.tile_size)

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		time := f32(rl.GetTime())
		entities.update_camera(&rts_cam)
		states.update_controls(&controls, dt)

		mouse_screen_pos := rl.GetMousePosition()
		mouse_world := rl.GetScreenToWorld2D(mouse_screen_pos, rts_cam.rl_camera)
		hover_x, hover_y := core.screen_to_iso(mouse_world, controls.tile_size)
		if rl.IsKeyPressed(.F6) {
			controls.tile_size += 10.0
			shader = gfx.init_shader(SHADER_FS, SHADER_VS, MAP_SIZE, &controls)
			game.atlas = gfx.init_atlas(controls.tile_size)
		}
		if rl.IsKeyPressed(.F5) {
			controls.tile_size -= 10.0
			if controls.tile_size < 10.0 do controls.tile_size = 10.0
			shader = gfx.init_shader(SHADER_FS, SHADER_VS, MAP_SIZE, &controls)
			game.atlas = gfx.init_atlas(controls.tile_size)
		}
		// if rl.IsKeyPressed(.F5) {
		// 	core.save_map(&iso_world, "level_data.bin")
		// }

		// if rl.IsKeyPressed(.F6) {
		// 	world.destroy_map(&iso_world)
		// 	iso_world = core.load_map("level_data.bin")
		// 	map_height_loc := rl.GetShaderLocation(shader, "mapHeight")

		// 	new_pixel_height := f32(f32(iso_world.height) * controls.tile_size / 2) + 2000.0
		// 	rl.SetShaderValue(shader, map_height_loc, &new_pixel_height, .FLOAT)
		// }

		if !controls.paused {
			if controls.state == states.RunState.LEVEL {
				states.update_flat(&iso_world, &controls, time)
			} else if controls.state == states.RunState.EDITOR {
				//
			} else if controls.state == states.RunState.SIMULATION {
				states.update_simulation(&iso_world, &controls, time)
			} else if controls.state == states.RunState.MENU {
				states.generate_simple_menu(&iso_world)
				states.update_simple_menu(&iso_world, &controls, time, hover_x, hover_y)

			}
		}
		ui.update_variable(&debugPanel, "Hover", core.Point{hover_x, hover_y})
		ui.update_variable(&debugPanel, "MODE (Tab)", controls.active_type)
		ui.update_variable(&debugPanel, "Speed (1/3)", controls.speed)
		ui.update_variable(&debugPanel, "Freq (7/9)", controls.frequency)
		ui.update_variable(&debugPanel, "Amp (Up/Dn)", controls.amplitude)
		ui.update_variable(&debugPanel, "Steps (-/+)", controls.steps)
		ui.update_variable(&debugPanel, "State (F2)", controls.state)
		ui.update_variable(&debugPanel, "Theme (C)", utils.THEMES[controls.palette_idx].name)
		ui.update_variable(&debugPanel, "Paused (Pause)", controls.paused)
		ui.update_variable(&debugPanel, "Tile Size (F5/F6)", controls.tile_size)


		gfx.render_iso_map(&iso_world, &rts_cam, shader, &controls, &game.atlas, &debugPanel)

	}

}
