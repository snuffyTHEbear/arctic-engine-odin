package ui

import "../core"
import "../states"
import "core:fmt"
import "core:strings"

VarValue :: union {
	int,
	f32,
	string,
	bool,
	i32,
	states.WaveType,
	core.Point,
}

DebugPanel :: struct {
	variables: map[string]VarValue,
}

add_variable :: proc(dp: ^DebugPanel, name: string, value: VarValue) {
	key := strings.clone(name)
	dp.variables[key] = value
	fmt.printf("Stored variable '%s'\n", key)
}

update_variable :: proc(dp: ^DebugPanel, name: string, value: VarValue) {
	dp.variables[name] = value
	fmt.printf("Updated variable '%s'\n", name)

}

init_debug_panel :: proc() -> DebugPanel {
	return DebugPanel{variables = make(map[string]VarValue)}
}

destroy_debug_panel :: proc(dp: ^DebugPanel) {
	delete(dp.variables)
}
