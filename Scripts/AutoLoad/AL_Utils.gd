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

func CenterToTilemap (tilemap, pos):
	return pos + tilemap.cell_size / 2.0
