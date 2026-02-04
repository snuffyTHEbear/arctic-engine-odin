package states

import "../world"
import "core:math"
import rl "vendor:raylib"

update_simulation :: proc(iso_world: ^world.IsoMap, controls: ^Controls, time: f32) {
	for y in 0 ..< iso_world.height {
		for x in 0 ..< iso_world.width {
			cx := f32(iso_world.width) / 2.0
			cy := f32(iso_world.height) / 2.0
			dx := f32(x) - cx
			dy := f32(y) - cy
			dist := math.sqrt_f32(dx * dx + dy * dy)

			idx := world.get_tile_index(iso_world, x, y)

			offset := f32(0.0)

			switch controls.active_type {
			// case .NONE:
			//     offset = 0.0
			case .FLAT:
				offset = controls.amplitude
			case .DIAGONAL:
				dist = f32(x + y)
				offset = math.sin_f32(time * controls.speed + dist * controls.frequency)
			case .CIRCULAR:
				offset = math.sin_f32(time * controls.speed - dist * controls.frequency)
			case .NOISE:
				offset = math.sin_f32(time * 5.0 + f32(idx))
			case .SPIRAL:
				angle := math.atan2_f32(dy, dx)
				offset = math.sin_f32(
					time * controls.speed - dist * controls.frequency + angle * 5.0,
				)
			case .INTERFERANCE:
				w1 := math.sin_f32(time * controls.speed + f32(x) * controls.frequency)
				w2 := math.sin_f32(time * controls.speed + f32(y) * controls.frequency)
				offset = (w1 + w2) * 5.0
			case .BOUNCE:
				raw_sine := math.sin_f32(time * controls.speed + dist * controls.frequency)
				offset = math.abs(raw_sine)
			case .GLITCH:
				val := math.tan_f32(time * 5.0 + dist * 0.1)
				offset = rl.Clamp(val, -1.0, 1.0)
			case .SQUARE:
				raw_val := math.sin_f32(time * controls.speed + dist * controls.frequency)
				if raw_val > 0 {
					offset = 1.0
				} else {
					offset = -1.0
				}
			case .SAWTOOTH:
				input_val := (time * controls.speed + dist * controls.frequency)
				offset = math.mod_f32(input_val, 1.0) * 2.0 - 1.0
			case .TRIANGLE:
				input_val := (time * controls.speed + dist * controls.frequency) * 0.5
				offset = 2.0 * math.abs(2.0 * (input_val - math.floor_f32(input_val + 0.5))) - 1.0
			case .STEPPED:
				raw_sine := math.sin_f32(time * controls.speed + dist * controls.frequency)
				offset = math.floor_f32(raw_sine * controls.steps) / controls.steps
			case .BINARY_NOISE:
				step_time := math.floor_f32(time * 4.0)
				block_size := int(controls.steps)
				bx := int(x) / block_size
				by := int(y) / block_size

				hash := (bx * 73856093) ~ (by * 19349663) ~ (int(step_time) * 83492791)

				if (hash & 1) == 0 {
					offset = -1.0
				} else {
					offset = 1.0
				}


			// t_int := int(time * 10.0)
			// val := (x * y * t_int) & 1
			// offset = f32(val * 2 - 1)
			}
			iso_world.tile_heights[idx] = offset * controls.amplitude //BASE_HEIGHT + (offset * WAVE_AMP)
		}
	}
}
