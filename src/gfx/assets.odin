package gfx

import "../world"
import rl "vendor:raylib"

Atlas :: struct {
	texture: rl.Texture,
	sprites: [world.TileType.COUNT]rl.Rectangle,
}

s :: proc(val: i32, scale: i32) -> i32 {
	return val * scale
}

init_atlas :: proc(tile_size: f32) -> Atlas {

	ATLAS_WIDTH :: 128
	ATLAS_HEIGHT :: 128
	SCALE_FACTOR :: 8

	canvas_w := i32(ATLAS_WIDTH * SCALE_FACTOR)
	canvas_h := i32(ATLAS_HEIGHT * SCALE_FACTOR)
	img := rl.GenImageColor(canvas_w, canvas_h, rl.BLANK)

	//rl.ImageDrawRectangle(img, 0, 0, tile_size, tile_size, rl.PINK)
	// rl.ImageDrawTriangle(img, {}, {}, {}, rl.PINK)
	// rect := rl.Rectangle {
	// 	f32(s(0, SCALE_FACTOR)),
	// 	f32(s(0, SCALE_FACTOR)),
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// }

	rl.ImageDrawRectangle(
		&img,
		s(0, SCALE_FACTOR),
		s(0, SCALE_FACTOR),
		s(i32(tile_size), SCALE_FACTOR),
		s(i32(tile_size), SCALE_FACTOR),
		rl.WHITE,
	)
	//rl.ImageDrawRectangleLines(&img, rect, s(0, SCALE_FACTOR), rl.BLACK)


	// rect2 := rl.Rectangle {
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// 	f32(s(0, SCALE_FACTOR)),
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// }
	rl.ImageDrawRectangle(
		&img,
		s(i32(tile_size), SCALE_FACTOR),
		s(0, SCALE_FACTOR),
		s(i32(tile_size), SCALE_FACTOR),
		s(i32(tile_size), SCALE_FACTOR),
		rl.WHITE,
	)

	// rect3 := rl.Rectangle {
	// 	f32(s(0, SCALE_FACTOR)),
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// 	f32(s(i32(tile_size), SCALE_FACTOR)),
	// }
	rl.ImageDrawRectangle(
		&img,
		s(0, SCALE_FACTOR),
		s(i32(tile_size), SCALE_FACTOR),
		s(i32(tile_size), SCALE_FACTOR),
		s(i32(tile_size), SCALE_FACTOR),
		rl.WHITE,
	)


	//rl.ImageDrawRectangleLines(&img, rect2, s(1, SCALE_FACTOR), rl.BEIGE)
	//rl.ImageDrawTriangleLines(&img, {tile_size, 0}, {128,0}, {tile_size, 0}, rl.PURPLE)

	// rl.ImageDrawCircle(&img, s(80,SCALE_FACTOR), s(20, SCALE_FACTOR), s(6,SCALE_FACTOR), rl.PINK)
	// rl.ImageDrawCircle(&img, s(110,SCALE_FACTOR), s(20, SCALE_FACTOR), s(6,SCALE_FACTOR), rl.PINK)

	rl.ImageResizeNN(&img, ATLAS_WIDTH, ATLAS_HEIGHT)

	tex := rl.LoadTextureFromImage(img)
	rl.SetTextureFilter(tex, .BILINEAR)

	rl.UnloadImage(img)

	a := Atlas {
		texture = tex,
	}
	a.sprites[world.TileType.WHITE] = {0, 0, tile_size, tile_size}
	a.sprites[world.TileType.BOB] = {tile_size, 0, tile_size, tile_size}
	a.sprites[world.TileType.BLANK] = {0, tile_size, tile_size, tile_size}

	return a
}

destroy_atlas :: proc(a: ^Atlas) {
	rl.UnloadTexture(a.texture)
}
