package world

TileType :: enum {
	WHITE,
	BOB,
	BLANK,
	COUNT,
}

IsoMap :: struct {
	width:        int,
	height:       int,
	tile_ids:     []TileType,
	tile_heights: []f32,
	flags:        []u8,
}

init_map :: proc(w, h: int) -> IsoMap {
	m := IsoMap {
		width  = w,
		height = h,
	}

	count := w * h

	m.tile_ids = make([]TileType, count)
	m.tile_heights = make([]f32, count)
	m.flags = make([]u8, count)

	return m
}

destroy_map :: proc(m: ^IsoMap) {
	delete(m.tile_ids)
	delete(m.tile_heights)
	delete(m.flags)
}

@(optimization_mode = "favor_size")
get_tile_index :: proc(m: ^IsoMap, x, y: int) -> int {
	if x < 0 || x >= m.width || y < 0 || y >= m.height {
		return -1
	}
	return (y * m.width) + x
}

set_tile :: proc(m: ^IsoMap, x, y: int, type: TileType, h: f32) {
	idx := get_tile_index(m, x, y)
	if idx != -1 {
		// m.tile_ids[idx]     = id
		// m.tile_heights[idx] = h
		m.tile_ids[idx] = type
		m.tile_heights[idx] = h
	}
}
