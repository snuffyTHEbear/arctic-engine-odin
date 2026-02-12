package states
import "../world"
import "core:math"

generate_simple_menu :: proc(isomap: ^world.IsoMap) {
	for y in 0 ..< isomap.height {
		for x in 0 ..< isomap.width {
			idx := world.get_tile_index(isomap, x, y)
			isomap.tile_ids[idx] = .WHITE
			isomap.tile_heights[idx] = 0.0
		}
	}
}

update_simple_menu :: proc(
	isomap: ^world.IsoMap,
	controls: ^Controls,
	time: f32,
	hover_x: int,
	hover_y: int,
) {
	apply_mouse_plateau(isomap, controls, time, hover_x, hover_y)
	// for y in 0 ..< isomap.height {
	// 	for x in 0 ..< isomap.width {
	// 		idx := world.get_tile_index(isomap, x, y)
	// 		if x == hover_x && y == hover_y {
	// 			isomap.tile_heights[idx] = controls.amplitude + 50.0
	// 		} else {
	// 			isomap.tile_heights[idx] = controls.amplitude
	// 		}
	// 	}
	// }
}

apply_mouse_plateau :: proc(
	isomap: ^world.IsoMap,
	controls: ^Controls,
	time: f32,
	hover_x: int,
	hover_y: int,
) {
	//Add to controls
	RADIUS :: 6.0
	PEAK_H :: 50.0 // amplitude?
	STEP_SIZE :: 10.0 // steps

	for i in 0 ..< len(isomap.tile_heights) {
		isomap.tile_heights[i] = 0.0
	}

	min_x := int(math.max(0.0, f32(hover_x) - RADIUS))
	max_x := int(math.min(f32(isomap.width), f32(hover_x) + RADIUS + 1))
	min_y := int(math.max(0.0, f32(hover_y) - RADIUS))
	max_y := int(math.min(f32(isomap.height), f32(hover_y) + RADIUS + 1))

	for y in min_x ..< max_x {
		for x in min_y ..< max_y {
			dx := f32(x - hover_x)
			dy := f32(y - hover_y)
			dist := math.sqrt(dx * dx + dy * dy)

			if dist < RADIUS {
				t := 1.0 - (dist / RADIUS)
				//SMOOTHER
				//t = t * t * (3.0 - 2.0 * t)

				h := t * PEAK_H

				h = math.floor(h / STEP_SIZE) * STEP_SIZE

				idx := world.get_tile_index(isomap, x, y)
				if idx >= 0 {
					isomap.tile_heights[idx] = h
				}
			}
		}
	}
}
