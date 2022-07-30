extends Node

#
# Public
#

func RandSign ():
	randomize()
	return [-1, 1][randi() % 2]

func IsMouseOnControl (node: Control):
	return node.get_global_rect().has_point(node.get_global_mouse_position())

func RemoveChildren (node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func HasChild (node: Node, idx):
	return idx < node.get_child_count()

func GetChildOrNull (node: Node, idx):
	if HasChild(node, idx):
		return node.get_child(idx)
	return null

func TilemapMapToWorldCentered (tilemap, map_pos):
	return tilemap.map_to_world(map_pos) + tilemap.cell_size / 2.0

func TilemapWorldCentered (tilemap, pos):
	return TilemapMapToWorldCentered(tilemap, tilemap.world_to_map(pos))

func TilemapIsAnyOf (tilemap, cell_idx, tile_names):
	for tile_name in tile_names:
		if cell_idx == tilemap.tile_set.find_tile_by_name(tile_name):
			return true
	return false

func TilemapSetCell (tilemap, pos, tile_name):
	tilemap.set_cellv(pos, tilemap.tile_set.find_tile_by_name(tile_name))
	
func TilemapSetRandomCell (tilemap, pos, tile_name_1, tile_name_2):
	randomize()
	if randf() < 0.5 : TilemapSetCell(tilemap, pos, tile_name_1)
	else             : TilemapSetCell(tilemap, pos, tile_name_2)

func TilemapHasCell (tilemap, pos):
	return tilemap.get_cellv(pos) >= 0
	
func TilemapCellData (pos, id, orientation = 0):
	var x = int(pos.x) & 0xffff
	var y = (int(pos.y) & 0xffff) << 16
	var coord = x + y
	return [coord, id, orientation]
