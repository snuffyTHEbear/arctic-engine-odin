package main

import "core:math"
import "core:slice"

Point :: [2]int

MAX_HEIGHT_DIFF :: 10.0

Pathfinder :: struct
{
    width, height:  int,
    came_from:      []int,
    g_score:        []f32,
    f_score:        []f32,
    in_open_set:    []bool,
}

init_pathfinder :: proc(w, h: int) -> Pathfinder{
    count := w * h
    return Pathfinder{
        width = w, height = h,
        came_from   = make([]int, count),
        g_score     = make([]f32, count),
        f_score     = make([]f32, count),
        in_open_set = make([]bool, count),
    }
}

destroy_pathfinder :: proc(pf: ^Pathfinder){
    delete(pf.came_from)
    delete(pf.g_score)
    delete(pf.f_score)
    delete(pf.in_open_set)
}

heuristic :: proc(a, b: Point) -> f32{
    return f32(math.abs(a.x - b.x) + math.abs(a.y - b.y))
}

find_path :: proc(pf: ^Pathfinder, world: ^IsoMap, start, end :Point) -> [dynamic]Point{
    slice.fill(pf.g_score, 999999.0)
    slice.fill(pf.f_score, 999999.0)
    slice.fill(pf.in_open_set, false)
    slice.fill(pf.came_from, -1)

    start_idx := get_tile_index(world, start.x, start.y)
    end_idx   := get_tile_index(world, end.x, end.y)

    if start_idx == -1 || end_idx == -1{ return nil }

    pf.g_score[start_idx] = 0.0
    pf.f_score[start_idx] = heuristic(start, end)

    open_set := make([dynamic]int)
    defer delete(open_set)
    append(&open_set, start_idx)
    pf.in_open_set[start_idx] = true

    for len(open_set) > 0{
        lowest_f := f32(999999.0)
        current_idx := -1
        current_list_idx := -1

        for idx, i in open_set{
            if pf.f_score[idx] < lowest_f{
                lowest_f = pf.f_score[idx]
                current_idx = idx
                current_list_idx = i
            }
        }

        if current_idx == end_idx
        {
            return reconstruct_path(pf, world, current_idx)
        }

        unordered_remove(&open_set, current_list_idx)
        pf.in_open_set[current_idx] = false

        cx := current_idx % world.width
        cy := current_idx / world.width

        neighbours := [4]Point{
            {cx + 1, cy},
            {cx - 1, cy},
            {cx, cy + 1},
            {cx, cy - 1},
        }

        for n in neighbours
        {
            if n.x < 0 || n.x >= world.width || n.y < 0 || n.y >= world.height
            {
                continue
            }

            n_idx:= get_tile_index(world, n.x, n.y)
            height_diff := math.abs(world.tile_heights[n_idx] - world.tile_heights[current_idx])

            if height_diff > MAX_HEIGHT_DIFF
            {
                continue
            }

            movement_cost := 1.0 + (height_diff * 0.5)

            tentative_g := pf.g_score[current_idx] + movement_cost

            if tentative_g < pf.g_score[n_idx]
            {
                pf.came_from[n_idx]     = current_idx
                pf.g_score[n_idx]       = tentative_g
                pf.f_score[n_idx]       = tentative_g + heuristic(n, end)

                if !pf.in_open_set[n_idx]
                {
                    append(&open_set, n_idx)
                    pf.in_open_set[n_idx] = true
                }
            }
        }
    }
    return nil
}

reconstruct_path :: proc(pf : ^Pathfinder, world: ^IsoMap, current_idx:int) -> [dynamic]Point{
    path := make([dynamic]Point)
    curr := current_idx

    for curr != -1
    {
        x := curr % world.width
        y := curr / world.width
        append(&path, Point{x, y})
        curr = pf.came_from[curr]
    }
    slice.reverse(path[:])
    return path
}