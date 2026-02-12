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
	{"Kernel", hex_to_color(0xFFFFFF), hex_to_color(0x0000AA)}, // Blue Screen of Death
	{"Missing", hex_to_color(0xFF00FF), hex_to_color(0x1A1A1A)}, // Missing Texture Magenta
	{"Artifact", hex_to_color(0xADFF2F), hex_to_color(0x4B0082)}, // GPU Overheating
	{"Scanline", hex_to_color(0x00FFFF), hex_to_color(0x221100)}, // CRT Desync
	{"Invert", hex_to_color(0xFF5F00), hex_to_color(0x00454E)}, // Buffer Inversion
	{"Marker", hex_to_color(0xD98E5F), hex_to_color(0x2B1111)}, // Rusty/Bloody
	{"Acheron", hex_to_color(0x7FB3D5), hex_to_color(0x050A0E)}, // Biomechanical Blue
	{"Singularity", hex_to_color(0x9B59B6), hex_to_color(0x020205)}, // Void Purple
	{"Talos", hex_to_color(0xFFE5B4), hex_to_color(0x0D1B1E)}, // Corrupted Tech
	{"Annihilation", hex_to_color(0xFF00FF), hex_to_color(0x1A2408)}, // Cosmic Mutation
	{"Nostromo", hex_to_color(0xE3D985), hex_to_color(0x081217)},
	{"Citadel", hex_to_color(0x56CCF2), hex_to_color(0x0F0F0F)},
	{"System", hex_to_color(0x00FF41), hex_to_color(0x0D0208)},
	{"Solaris", hex_to_color(0xEEEBDD), hex_to_color(0x1B4B4A)},
	{"The Lodge", hex_to_color(0xF3E5AB), hex_to_color(0x660000)},
	{"Spirit", hex_to_color(0xCCFF66), hex_to_color(0x004D2C)},
	{"Tartarus", hex_to_color(0xFF6A00), hex_to_color(0x2D004B)},
	{"Arrakis", hex_to_color(0xFFF1D0), hex_to_color(0x7B3F00)},
	{"Wallace", hex_to_color(0xFF8C00), hex_to_color(0x3E1F00)},
	{"Citrus", PASTEL.Orange, PASTEL.TeaGreen},
	{"Arctic", PASTEL.Blue, rl.WHITE}, // Standard engine look
	{"Sunset", PASTEL.Red, PASTEL.Yellow}, // Warm
	{"Berry", PASTEL.Violet, PASTEL.Lavender}, // Purple
	{"Forest", rl.DARKGREEN, PASTEL.Green}, // Dark to light green
	{"PS2 Boot", rl.Color{0x11, 0x0C, 0x2E, 0xFF}, rl.Color{0xD8, 0x11, 0x59, 0xFF}},
	{"Tactical", hex_to_color(0xF58231), hex_to_color(0x004156)},
	{"Restless", hex_to_color(0xD6C8BD), hex_to_color(0x4A0808)},
	{"Colossus", hex_to_color(0xFFFDD0), hex_to_color(0x3B2F2F)},
	{"Cosmic", hex_to_color(0x75F649), hex_to_color(0xE91E63)},
	{"Zanarkand", hex_to_color(0x3D8DF2), hex_to_color(0xF8D034)},
	{"Spartan", hex_to_color(0xEBEBEB), hex_to_color(0x8B0000)},
	{"Vice", hex_to_color(0x00FFFF), hex_to_color(0xFF00FF)},
}

hex_to_color :: proc "contextless" (hex: int) -> rl.Color {
	r := u8((hex >> 16) & 0xFF)
	g := u8((hex >> 8) & 0xFF)
	b := u8(hex & 0xFF)
	return rl.Color{r, g, b, 255}
}
