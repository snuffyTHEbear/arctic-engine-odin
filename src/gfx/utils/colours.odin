package utils

import rl "vendor:raylib"

PastelPalette :: struct {
	Red:      rl.Color,
	Orange:   rl.Color,
	Yellow:   rl.Color,
	Green:    rl.Color,
	Blue:     rl.Color,
	Violet:   rl.Color,
	TeaGreen: rl.Color,
	Peach:    rl.Color,
	Salmon:   rl.Color,
	Lavender: rl.Color,
}

// Define the constants
PASTEL :: PastelPalette {
	Red      = rl.Color{0xFF, 0xB3, 0xBA, 0xFF}, // 0xFFB3BA
	Orange   = rl.Color{0xFF, 0xDF, 0xBA, 0xFF}, // 0xFFDFBA
	Yellow   = rl.Color{0xFF, 0xFF, 0xBA, 0xFF}, // 0xFFFFBA
	Green    = rl.Color{0xBA, 0xFF, 0xC9, 0xFF}, // 0xBAFFC9
	Blue     = rl.Color{0xBA, 0xE1, 0xFF, 0xFF}, // 0xBAE1FF
	Violet   = rl.Color{0xC7, 0xCE, 0xEA, 0xFF}, // 0xC7CEEA
	TeaGreen = rl.Color{0xE2, 0xF0, 0xCB, 0xFF}, // 0xE2F0CB
	Peach    = rl.Color{0xFF, 0xDA, 0xC1, 0xFF}, // 0xFFDAC1
	Salmon   = rl.Color{0xFF, 0x9A, 0xA2, 0xFF}, // 0xFF9AA2
	Lavender = rl.Color{0xE0, 0xBB, 0xE4, 0xFF}, // 0xE0BBE4
}

Theme :: struct {
	name: string,
	low:  rl.Color,
	high: rl.Color,
}

THEMES := [?]Theme {
	{"Citrus", PASTEL.Orange, PASTEL.TeaGreen}, // The one you requested
	{"Arctic", PASTEL.Blue, rl.WHITE}, // Standard engine look
	{"Sunset", PASTEL.Red, PASTEL.Yellow}, // Warm
	{"Berry", PASTEL.Violet, PASTEL.Lavender}, // Purple
	{"Forest", rl.DARKGREEN, PASTEL.Green}, // Dark to light green
	{"PS2 Boot", rl.Color{0x11, 0x0C, 0x2E, 0xFF}, rl.Color{0xD8, 0x11, 0x59, 0xFF}},
	// ... your existing themes ...

	// METAL GEAR SOLID 2: The "Big Shell" Look
	// High: The harsh, sunset orange of the strut bridges
	// Low:  The deep, murky sea green of the water below
	{"Tactical", hex_to_color(0xF58231), hex_to_color(0x004156)},

	// SILENT HILL 2: Psychological Horror
	// High: The "Fog World" white (slightly warm/dirty)
	// Low:  The "Otherworld" dried rust/blood red
	{"Restless", hex_to_color(0xD6C8BD), hex_to_color(0x4A0808)},

	// SHADOW OF THE COLOSSUS: The Forbidden Land
	// High: That over-bloomed, blinding sky white
	// Low:  The desaturated, organic brown of colossus fur
	{"Colossus", hex_to_color(0xFFFDD0), hex_to_color(0x3B2F2F)},

	// KATAMARI DAMACY: Na na na...
	// High: The iconic "Prince" neon green
	// Low:  The hot pink of the UI/Royalty (creates a wild gradient!)
	{"Cosmic", hex_to_color(0x75F649), hex_to_color(0xE91E63)},

	// FINAL FANTASY X: Besaid Island
	// High: The vivid tropical sky/water blue
	// Low:  The warm, sandy beach yellow/orange
	{"Zanarkand", hex_to_color(0x3D8DF2), hex_to_color(0xF8D034)},

	// GOD OF WAR: Spartan Rage
	// High: Ash White (Kratos' skin)
	// Low:  Spartan Red (Tattoos/Cloth)
	{"Spartan", hex_to_color(0xEBEBEB), hex_to_color(0x8B0000)},

	// GTA VICE CITY: Neon Nights
	// High: Cyan (The water/HUD)
	// Low:  Magenta (The sunset/UI) - Classic Vaporwave/Outrun origin
	{"Vice", hex_to_color(0x00FFFF), hex_to_color(0xFF00FF)},
}

hex_to_color :: proc "contextless" (hex: int) -> rl.Color {
	r := u8((hex >> 16) & 0xFF)
	g := u8((hex >> 8) & 0xFF)
	b := u8(hex & 0xFF)
	return rl.Color{r, g, b, 255}
}
