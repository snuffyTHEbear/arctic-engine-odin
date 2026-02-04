package core

import "core:math"
import rl "vendor:raylib"

TILE_WIDTH :: 64
TILE_HEIGHT :: 32

TILE_HALF_W :: TILE_WIDTH / 2
TILE_HALF_H :: TILE_HEIGHT / 2

Point :: struct {
	x: int,
	y: int,
}

//grid to world
iso_to_screen :: proc(x, y: int) -> rl.Vector2 {
	screen_x := f32(x - y) * TILE_HALF_W
	screen_y := f32(x + y) * TILE_HALF_H

	return rl.Vector2{screen_x, screen_y}
}

iso_to_screen_float :: proc(x, y: f32) -> rl.Vector2 {
	tile_w := f32(TILE_WIDTH)
	tile_h := f32(TILE_HEIGHT)
	screen_x := (x - y) * (tile_w * 0.5)
	screen_y := (x + y) * (tile_h * 0.5)
	offset_x := f32(rl.GetScreenWidth()) * 0.5
	offset_y := f32(rl.GetScreenHeight()) * 0.5
	return rl.Vector2{screen_x + offset_x, screen_y + offset_y}
}

//world to grid
screen_to_iso :: proc(pos: rl.Vector2) -> (int, int) {
	adjusted_x := pos.x
	adjusted_y := pos.y + TILE_HALF_H

	x := (adjusted_y / TILE_HALF_H + adjusted_x / TILE_HALF_W) / 2
	y := (adjusted_y / TILE_HALF_H - adjusted_x / TILE_HALF_W) / 2

	return int(math.floor(x)), int(math.floor(y))
}

get_visible_tiles :: proc(cam: rl.Camera2D, map_w, map_h: int) -> (int, int, int, int) {
	top_left := rl.GetScreenToWorld2D({0, 0}, cam)
	bottom_right := rl.GetScreenToWorld2D(
		{f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())},
		cam,
	)

	iso_tl_x, iso_tl_y := screen_to_iso(top_left)
	iso_br_x, iso_br_y := screen_to_iso(bottom_right)
	iso_tr_x, iso_tr_y := screen_to_iso(rl.Vector2{bottom_right.x, top_left.y})
	iso_bl_x, iso_bl_y := screen_to_iso(rl.Vector2{top_left.x, bottom_right.y})

	min_x := min(iso_tl_x, min(iso_br_x, min(iso_tr_x, iso_bl_x)))
	max_x := max(iso_tl_x, max(iso_br_x, max(iso_tr_x, iso_bl_x)))
	min_y := min(iso_tl_y, min(iso_br_y, min(iso_tr_y, iso_bl_y)))
	max_y := max(iso_tl_y, max(iso_br_y, max(iso_tr_y, iso_bl_y)))

	if min_x < 0 do min_x = 0
	if min_y < 0 do min_y = 0
	if max_x >= map_w do max_x = map_w - 1
	if max_y >= map_h do max_y = map_h - 1

	return min_x, min_y, max_x, max_y
}
