package main

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
    Red      = rl.Color{ 0xFF, 0xB3, 0xBA, 0xFF }, // 0xFFB3BA
    Orange   = rl.Color{ 0xFF, 0xDF, 0xBA, 0xFF }, // 0xFFDFBA
    Yellow   = rl.Color{ 0xFF, 0xFF, 0xBA, 0xFF }, // 0xFFFFBA
    Green    = rl.Color{ 0xBA, 0xFF, 0xC9, 0xFF }, // 0xBAFFC9
    Blue     = rl.Color{ 0xBA, 0xE1, 0xFF, 0xFF }, // 0xBAE1FF
    Violet   = rl.Color{ 0xC7, 0xCE, 0xEA, 0xFF }, // 0xC7CEEA
    TeaGreen = rl.Color{ 0xE2, 0xF0, 0xCB, 0xFF }, // 0xE2F0CB
    Peach    = rl.Color{ 0xFF, 0xDA, 0xC1, 0xFF }, // 0xFFDAC1
    Salmon   = rl.Color{ 0xFF, 0x9A, 0xA2, 0xFF }, // 0xFF9AA2
    Lavender = rl.Color{ 0xE0, 0xBB, 0xE4, 0xFF }, // 0xE0BBE4
}

hex_to_colour :: proc(hex: int) -> rl.Color{
    r := u8((hex >> 16) & 0xFF)
    g := u8((hex >> 8) & 0xFF)
    b := u8(hex & 0xFF)
    return rl.Color{r, g, b, 255}
}