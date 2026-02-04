package gfx

import "../world"
import rl "vendor:raylib"

SPRITE_TILE_WIDTH :: 16
SPRITE_TILE_HEIGHT :: 16


Atlas :: struct {
	texture: rl.Texture,
	sprites: [world.TileType.COUNT]rl.Rectangle,
}

s :: proc(val: i32, scale: i32) -> i32 {
	return val * scale
}

init_atlas :: proc() -> Atlas {

	ATLAS_WIDTH :: 128
	ATLAS_HEIGHT :: 128
	SCALE_FACTOR :: 8

	canvas_w := i32(ATLAS_WIDTH * SCALE_FACTOR)
	canvas_h := i32(ATLAS_HEIGHT * SCALE_FACTOR)
	img := rl.GenImageColor(canvas_w, canvas_h, rl.BLANK)

	//rl.ImageDrawRectangle(img, 0, 0, 64, 64, rl.PINK)
	// rl.ImageDrawTriangle(img, {}, {}, {}, rl.PINK)
	rect := rl.Rectangle {
		f32(s(0, SCALE_FACTOR)),
		f32(s(0, SCALE_FACTOR)),
		f32(s(64, SCALE_FACTOR)),
		f32(s(64, SCALE_FACTOR)),
	}

	rl.ImageDrawRectangle(
		&img,
		s(0, SCALE_FACTOR),
		s(0, SCALE_FACTOR),
		s(64, SCALE_FACTOR),
		s(64, SCALE_FACTOR),
		rl.WHITE,
	)
	rl.ImageDrawRectangleLines(&img, rect, s(0, SCALE_FACTOR), rl.BLACK)


	rect2 := rl.Rectangle {
		f32(s(64, SCALE_FACTOR)),
		f32(s(0, SCALE_FACTOR)),
		f32(s(64, SCALE_FACTOR)),
		f32(s(64, SCALE_FACTOR)),
	}
	rl.ImageDrawRectangle(
		&img,
		s(64, SCALE_FACTOR),
		s(0, SCALE_FACTOR),
		s(64, SCALE_FACTOR),
		s(64, SCALE_FACTOR),
		rl.ORANGE,
	)
	rl.ImageDrawRectangleLines(&img, rect2, s(1, SCALE_FACTOR), rl.BEIGE)
	//rl.ImageDrawTriangleLines(&img, {64, 0}, {128,0}, {64, 0}, rl.PURPLE)

	// rl.ImageDrawCircle(&img, s(80,SCALE_FACTOR), s(20, SCALE_FACTOR), s(6,SCALE_FACTOR), rl.PINK)
	// rl.ImageDrawCircle(&img, s(110,SCALE_FACTOR), s(20, SCALE_FACTOR), s(6,SCALE_FACTOR), rl.PINK)

	rl.ImageResizeNN(&img, ATLAS_WIDTH, ATLAS_HEIGHT)

	tex := rl.LoadTextureFromImage(img)
	rl.SetTextureFilter(tex, .BILINEAR)

	rl.UnloadImage(img)

	a := Atlas {
		texture = tex,
	}
	a.sprites[world.TileType.WHITE] = {0, 0, 64, 64}
	a.sprites[world.TileType.BOB] = {64, 0, 64, 64}

	return a
}

destroy_atlas :: proc(a: ^Atlas) {
	rl.UnloadTexture(a.texture)
}
