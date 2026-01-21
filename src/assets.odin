package main

import rl "vendor:raylib"

SPRITE_TILE_WIDTH :: 16
SPRITE_TILE_HEIGHT :: 16


//File types
TileType::enum{
    WHITE,
    BOB,
    COUNT,
}

Atlas :: struct {
    texture: rl.Texture,
    sprites: [TileType.COUNT]rl.Rectangle,
}

init_atlas ::proc() -> Atlas {
    img := rl.GenImageColor(128,128,rl.BLANK)
    
    //rl.ImageDrawRectangle(img, 0, 0, 64, 64, rl.PINK)
    // rl.ImageDrawTriangle(img, {}, {}, {}, rl.PINK)
    rect := rl.Rectangle{0,0,64,64}
    rl.ImageDrawRectangle(&img, 0, 0, 64, 64, rl.LIME)
    rl.ImageDrawRectangleLines(&img, rect, 2, rl.BLACK)
    
    
    rect2 := rl.Rectangle{64,0,64,64}
    //rl.ImageDrawRectangle(&img, 64, 0, 64, 64, rl.ORANGE)
    rl.ImageDrawRectangleLines(&img, rect2,5, rl.ORANGE)
    //rl.ImageDrawTriangleLines(&img, {64, 0}, {128,0}, {64, 0}, rl.PURPLE)    
    
    tex := rl.LoadTextureFromImage(img)

    rl.UnloadImage(img)
    a := Atlas{texture=tex}
    
    a.sprites[TileType.WHITE] = {0, 0, 64,64}
    a.sprites[TileType.BOB] = {64, 0, 64,64}

    return a
}

destroy_atlas :: proc(a: ^Atlas){
    rl.UnloadTexture(a.texture)
}