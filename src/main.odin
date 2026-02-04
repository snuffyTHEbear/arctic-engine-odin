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
MAP_SIZE_X :: 25
MAP_SIZE_Y :: 25
MAP_SIZE :: MAP_SIZE_X * MAP_SIZE_Y

SPEED :: 10.0
GRAVITY :: 40.0
JUMP_FORCE :: 15.0


SHADER_VS :: "./assets/shaders/iso_depth.vs"
SHADER_FS :: "./assets/shaders/iso_depth.fs"

Game :: struct {
	state:    states.RunState,
	isomap:   world.IsoMap,
	atlas:    gfx.Atlas,
	controls: states.Controls,
	camera:   entities.RTSCamera,
}

init_game :: proc() -> Game {
	g := Game {
		state    = states.RunState.SIMULATION,
		atlas    = gfx.init_atlas(),
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

	shader := rl.LoadShader(SHADER_VS, SHADER_FS)
	defer rl.UnloadShader(shader)

	pathfinder := core.init_pathfinder(MAP_SIZE_X, MAP_SIZE_Y)
	defer core.destroy_pathfinder(&pathfinder)

	controls := game.controls

	map_height_loc := rl.GetShaderLocation(shader, "mapHeight")
	if map_height_loc == -1 {
		fmt.println("Failed to get mapHeight uniform location in shader")
	}
	map_h_val: f32 = MAP_SIZE * gfx.TILE_SIZE + 2000.0
	rl.SetShaderValue(shader, map_height_loc, &map_h_val, .FLOAT)

	//atlas := game.atlas

	iso_world := game.isomap
	fmt.println("Engine started, Map Initialized")

	debugPanel := ui.init_debug_panel()
	defer ui.destroy_debug_panel(&debugPanel)

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

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		time := f32(rl.GetTime())
		entities.update_camera(&rts_cam)
		states.update_controls(&controls, dt)

		mouse_screen_pos := rl.GetMousePosition()
		mouse_world := rl.GetScreenToWorld2D(mouse_screen_pos, rts_cam.rl_camera)
		hover_x, hover_y := core.screen_to_iso(mouse_world)

		if rl.IsKeyPressed(.F5) {
			core.save_map(&iso_world, "level_data.bin")
		}

		if rl.IsKeyPressed(.F6) {
			world.destroy_map(&iso_world)
			iso_world = core.load_map("level_data.bin")

			new_pixel_height := f32(iso_world.height * 32) + 2000.0
			rl.SetShaderValue(shader, map_height_loc, &new_pixel_height, .FLOAT)
		}

		if !controls.paused {
			if controls.state == states.RunState.LEVEL {
				states.update_flat(&iso_world, &controls, time)
			} else if controls.state == states.RunState.EDITOR {
				//
			} else if controls.state == states.RunState.SIMULATION {
				states.update_simulation(&iso_world, &controls, time)
			}
		}
		ui.update_variable(&debugPanel, "Hover", core.Point{hover_x, hover_y})
		ui.update_variable(&debugPanel, "MODE (Tab)", controls.active_type)
		ui.update_variable(&debugPanel, "Speed (1/3)", controls.speed)
		ui.update_variable(&debugPanel, "Freq (7/9)", controls.frequency)
		ui.update_variable(&debugPanel, "Amp (Up/Dn)", controls.amplitude)
		ui.update_variable(&debugPanel, "Steps (-/+)", controls.steps)
		ui.update_variable(&debugPanel, "State (F2)", controls.state)

		gfx.render_iso_map(&iso_world, &rts_cam, shader, &controls, &game.atlas, &debugPanel)

	}

}
