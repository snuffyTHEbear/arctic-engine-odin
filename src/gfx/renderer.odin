package gfx

import "../core"
import "../entities"
import "../gfx"
import "../gfx/utils"
import "../states"
import "../ui"
import "../world"
import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

TILE_SIZE :: 64
TILE_OFFSET :: TILE_SIZE / 2

render_iso_map :: proc(
	isomap: ^world.IsoMap,
	camera: ^entities.RTSCamera,
	shader: rl.Shader,
	controls: ^states.Controls,
	atlas: ^gfx.Atlas,
	debugPanel: ^ui.DebugPanel,
) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLANK)
	rlgl.ClearScreenBuffers()
	current_theme := utils.THEMES[controls.palette_idx]

	rl.BeginMode2D(camera.rl_camera)
	rlgl.EnableDepthTest()
	rl.BeginShaderMode(shader)

	min_x, min_y, max_x, max_y := core.get_visible_tiles(
		camera.rl_camera,
		isomap.width,
		isomap.height,
	)

	for y := max_y; y >= min_y; y -= 1 {
		for x := max_x; x >= min_x; x -= 1 {
			idx := world.get_tile_index(isomap, x, y)
			h := isomap.tile_heights[idx]

			min_h := -controls.amplitude
			max_h := controls.amplitude
			range := max_h - min_h

			if range < 1.0 do range = 1.0

			t := (h - min_h) / range
			t = rl.Clamp(t, 0.0, 1.0)
			t = math.floor_f32(t * controls.steps) / controls.steps

			tile_colour := rl.ColorLerp(current_theme.low, current_theme.high, t)

			tile_type := isomap.tile_ids[idx]
			rect := atlas.sprites[tile_type]

			pos := core.iso_to_screen(x, y)

			visual_pos := rl.Vector2{pos.x - TILE_OFFSET, pos.y - TILE_OFFSET - h}

			s_idx := world.get_tile_index(isomap, x, y + 1)
			s_h := f32(-10.0)
			if s_idx != -1 do s_h = isomap.tile_heights[s_idx]

			if h > s_h {
				wall_colour := rl.ColorBrightness(tile_colour, -0.2) //rl.Color{200, 200, 200, 255}
				gfx.draw_wall(
					atlas.texture,
					rect,
					pos,
					h,
					s_h,
					gfx.WALL_TYPES.SOUTH_FACE,
					wall_colour,
				)
			}

			e_idx := world.get_tile_index(isomap, x + 1, y)
			e_h := f32(-10.0)
			if e_idx != -1 do e_h = isomap.tile_heights[e_idx]

			if h > e_h {
				wall_colour := rl.ColorBrightness(tile_colour, -0.4) //rl.Color{150, 150, 150, 255}
				gfx.draw_wall(
					atlas.texture,
					rect,
					pos,
					h,
					e_h,
					gfx.WALL_TYPES.EAST_FACE,
					wall_colour,
				)
			}

			gfx.draw_tile(atlas.texture, rect, visual_pos, pos.y, tile_colour)
			ui.update_variable(debugPanel, "Tiles Drawn", int((max_x - min_x) * (max_y - min_y)))
		}
	}
	rl.EndShaderMode()

	rlgl.DisableDepthTest()
	rl.EndMode2D()
	rl.DrawFPS(rl.GetScreenWidth() - 100, 10)
	//ADD DEBUG PANEL RENDERING HERE
	start_y :: 15
	step_y :: 25
	i := 0

	for key, value in debugPanel.variables {

		display_text: cstring

		switch v in value {
		case int:
			display_text = fmt.ctprintf("%s: %d", key, value)
		case f32:
			display_text = fmt.ctprintf("%s: %.2f", key, value)
		case string:
			display_text = fmt.ctprintf("%s: %s", key, value)
		case bool:
			display_text = fmt.ctprintf("%s: %t", key, value)
		case i32:
			display_text = fmt.ctprintf("%s: %d", key, value)
		case states.WaveType:
			display_text = fmt.ctprintf("%s: %v", key, value)
		case core.Point:
			display_text = fmt.ctprintf("%s: (%d, %d)", key, int(v.x), int(v.y))
		case states.RunState:
			display_text = fmt.ctprintf("%s: %v", key, value)
		}
		y_pos := i32(start_y + step_y * i)
		rl.DrawText(display_text, 15, y_pos, 20, rl.GREEN)
		i += 1
	}

	rl.EndDrawing()
}
