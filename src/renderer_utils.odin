package main

import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

WALL_TYPES :: enum {
    SOUTH_FACE=0, 
    EAST_FACE=1,
}

draw_tile :: proc(tex: rl.Texture, source: rl.Rectangle, visual_pos:rl.Vector2, sort_y: f32, color: rl.Color)
{
    //Check for flush
    rlgl.CheckRenderBatchLimit(4)
    rlgl.SetTexture(tex.id)

    //Calculate UV coords
    w       := f32(tex.width)
    h       := f32(tex.height)
    u_left  := source.x / w
    v_top   := source.y / h
    u_right := (source.x + source.width) / w
    v_bottom:= (source.y + source.height) / h

    width   := source.width
    height  := source.height
    half_width  := width / 2.0
    half_height := height / 2.0

    cx := visual_pos.x + half_width
    cy := visual_pos.y + half_height

    squash_factor :: 0.5

    rlgl.Begin(rlgl.QUADS)
        
        rlgl.Color4ub(color.r, color.g, color.b, color.a)
        
        //Bot Left
        rlgl.TexCoord2f(u_right, v_bottom)
        rlgl.Vertex3f(cx, cy + (half_height * squash_factor), sort_y)//(visual_pos.x , visual_pos.y + height, sort_y)

        //Bot Right
        rlgl.TexCoord2f(u_right, v_top)
        rlgl.Vertex3f(cx + half_width, cy, sort_y)//(visual_pos.x + width, visual_pos.y + height, sort_y)

        //Top Right
        rlgl.TexCoord2f(u_left, v_top)
        rlgl.Vertex3f(cx, cy - (half_height * squash_factor), sort_y)///(visual_pos.x + width, visual_pos.y, sort_y)

        //Top Left
        rlgl.TexCoord2f(u_left, v_bottom)
        rlgl.Vertex3f(cx - half_width, cy, sort_y)//(visual_pos.x , visual_pos.y, sort_y)
    rlgl.End()

}

draw_sprite :: proc(tex: rl.Texture, source: rl.Rectangle, visual_pos: rl.Vector2, sort_y: f32, color: rl.Color)
{
    //Check for flush
    rlgl.CheckRenderBatchLimit(4)
    rlgl.SetTexture(tex.id)

    //Calculate UV coords
    w       := f32(tex.width)
    h       := f32(tex.height)
    u_left  := source.x / w
    v_top   := source.y / h
    u_right := (source.x + source.width) / w
    v_bottom:= (source.y + source.height) / h

    width   := source.width
    height  := source.height

    rlgl.Begin(rlgl.QUADS)
        rlgl.Color4ub(color.r, color.g, color.b, color.a);
        rlgl.TexCoord2f(u_right, v_bottom);
        rlgl.Vertex3f(visual_pos.x, visual_pos.y +height, sort_y);
        rlgl.TexCoord2f(u_right, v_bottom);
        rlgl.Vertex3f(visual_pos.x + width, visual_pos.y + height, sort_y);
        rlgl.TexCoord2f(u_right, v_top);
        rlgl.Vertex3f(visual_pos.x + width, visual_pos.y, sort_y);
        rlgl.TexCoord2f(u_left, v_top);
        rlgl.Vertex3f(visual_pos.x, visual_pos.y, sort_y);

    rlgl.End()
}

draw_wall :: proc(tex: rl.Texture, source: rl.Rectangle, centre_pos:rl.Vector2, top_h: f32, bottom_h:f32, side_type:WALL_TYPES, tint: rl.Color)
{
    rlgl.CheckRenderBatchLimit(4)
    rlgl.SetTexture(tex.id)

    u_left := source.x / f32(tex.width)
    v_top := source.y / f32 (tex.height)

    u_right := (source.x + source.width) / f32(tex.width)
    v_bottom := (source.y + source.height) / f32(tex.height)

    half_width := source.width * 0.5
    half_height := (source.height * 0.5) * 0.5

    top_v1, top_v2 : rl.Vector2

    if side_type == WALL_TYPES.SOUTH_FACE 
    {
        top_v1 = { centre_pos.x - half_width, centre_pos.y }
        top_v2 = { centre_pos.x, centre_pos.y + half_height }
    }
    else
    {
        top_v1 = { centre_pos.x, centre_pos.y + half_height }
        top_v2 = { centre_pos.x + half_width, centre_pos.y}
    }

    //wall_height := top_h - bottom_h

    sort_y := (centre_pos.y) - 1.0

    rlgl.Begin(rlgl.QUADS)
        rlgl.Color4ub(tint.r, tint.g, tint.b, tint.a)

        rlgl.TexCoord2f(u_left, v_bottom)
        rlgl.Vertex3f(top_v1.x, top_v1.y - bottom_h, sort_y)

        rlgl.TexCoord2f(u_right, v_bottom)
        rlgl.Vertex3f(top_v2.x, top_v2.y - bottom_h, sort_y)

        rlgl.TexCoord2f(u_right, v_top,)
        rlgl.Vertex3f(top_v2.x, (top_v2.y - top_h) - 0.5, sort_y)

        rlgl.TexCoord2f(u_left, v_top)
        rlgl.Vertex3f(top_v1.x, (top_v1.y - top_h) - 0.5, sort_y)
    rlgl.End()
}