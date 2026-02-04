package states

import "../world"

update_flat :: proc(isomap: ^world.IsoMap, controls: ^Controls, time: f32) {
	for y in 0 ..< isomap.height {
		for x in 0 ..< isomap.width {
			idx := world.get_tile_index(isomap, x, y)
			isomap.tile_heights[idx] = 0
		}
	}
}

reset_flat :: proc(isomap: ^world.IsoMap) {
	for y in 0 ..< isomap.height {
		for x in 0 ..< isomap.width {
			idx := world.get_tile_index(isomap, x, y)
			isomap.tile_heights[idx] = 0.0
		}
	}
}
