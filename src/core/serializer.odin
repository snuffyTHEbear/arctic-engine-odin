package core

import "../world"
import "core:fmt"
import "core:mem"
import "core:os"

MapHeader :: struct {
	magic:  [4]u8,
	width:  i32,
	height: i32,
}

save_map :: proc(m: ^world.IsoMap, filename: string) -> bool {
	handle, err := os.open(filename, os.O_WRONLY | os.O_CREATE, 0o644)
	if err != os.ERROR_NONE {
		fmt.println("Failed to open file for saving: ", filename)
		return false
	}
	defer os.close(handle)

	header := MapHeader {
		magic  = {'I', 'S', 'O', '1'},
		width  = i32(m.width),
		height = i32(m.height),
	}

	os.write(handle, mem.ptr_to_bytes(&header))
	os.write(handle, slice_to_bytes(m.tile_ids))
	os.write(handle, slice_to_bytes(m.tile_heights))
	fmt.println("Map successfully saved to: ", filename)
	return true
}

load_map :: proc(filename: string) -> world.IsoMap {
	handle, err := os.open(filename, os.O_RDONLY, 0)
	if err != os.ERROR_NONE {
		fmt.println("Failed to find file: ", filename)
		return world.init_map(10, 10)
	}

	defer os.close(handle)

	header: MapHeader
	bytes_read, _ := os.read(handle, mem.ptr_to_bytes(&header))

	if bytes_read != size_of(MapHeader) || header.magic != {'I', 'S', 'O', '1'} {
		fmt.println("Error: Invalid map file format.")
		return world.init_map(10, 10)
	}
	w := int(header.width)
	h := int(header.height)
	new_map := world.init_map(w, h)
	os.read(handle, slice_to_bytes(new_map.tile_ids))
	os.read(handle, slice_to_bytes(new_map.tile_heights))
	fmt.println("Map successfully loaded: ", w, "x", h)
	return new_map
}

slice_to_bytes :: proc(data: $T/[]$E) -> []u8 {
	return mem.slice_to_bytes(data)
}
