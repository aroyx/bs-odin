package utils

IMGUI :: #config(IMGUI, true)
SERVER :: #config(SERVER, false)

map_size :: 256 + 1
MAP_SIZE :: map_size - 1
CHUNK_SIZE :: 32
GRID_SIZE :: MAP_SIZE / CHUNK_SIZE
