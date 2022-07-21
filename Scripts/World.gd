extends Node2D

export var __CHUNK_SIZE = Vector2(16, 16)
export var __SIMPLEX: OpenSimplexNoise = OpenSimplexNoise.new()
	
#
# World Generation
#

func __world_global_to_chunk (pos):
	pos = $TileMap.world_to_map(pos)
	pos += __CHUNK_SIZE / 2
	pos /= __CHUNK_SIZE
	return pos.floor()

func __world_chunk_to_map (pos):
	pos *= __CHUNK_SIZE
	pos -= __CHUNK_SIZE / 2
	return pos

func __world_set_cell (x, y, tile):
	$TileMap.set_cell(x, y, $TileMap.tile_set.find_tile_by_name(tile))

func __world_set_cell_5050 (x, y, tile1, tile2):
	if randf() < 0.5 : __world_set_cell(x, y, tile1)
	else             : __world_set_cell(x, y, tile2)

func __world_generate_chunk (chunk_pos):
	var map_pos = __world_chunk_to_map(chunk_pos)
	# chunk already generated
	if $TileMap.get_cellv(map_pos) >= 0:
		return
	
	randomize()
	for x in range(map_pos.x, map_pos.x + __CHUNK_SIZE.x):
		for y in range(map_pos.y, map_pos.y + __CHUNK_SIZE.y):
			var noise = __SIMPLEX.get_noise_2d(x, y)
			
			var is_water = (noise < 0.01)
			var is_sand  = (noise < 0.05)
			var is_tree  = (randf() < 0.05)

			if not is_water and not is_tree:
				$Navigation/TileMap.set_cell(x, y, $Navigation/TileMap.tile_set.find_tile_by_name("walkable"))

			if is_water:
				__world_set_cell(x, y, "water")
			elif is_sand:
				__world_set_cell_5050(x, y, "sand_1", "sand_2")
			else:
				__world_set_cell_5050(x, y, "grass", "grass_grass")
				if is_tree:
					var tree = SpawnEntity(
						$TileMap.to_global($TileMap.map_to_world(Vector2(x, y))),
						EntityData.new("tree")
					)
							
#
#
#

func __on_player_MoveEvent (pos):
	var chunk_pos = __world_global_to_chunk(pos)
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			__world_generate_chunk(chunk_pos + Vector2(x, y))
	
###
### DELETE
###
func __on_hour_changed (hour):
	print("Hour: ", hour)
	
func _enter_tree ():
	AL_Game.GameWorld = self
		
###
### DELETE
###
func _input (ev):
	if ev is InputEventMouseButton and not ev.pressed and ev.button_index == BUTTON_RIGHT:
		SpawnEntity(get_global_mouse_position(), EntityData.new("zombie"))
	
func _ready ():
	randomize()
	__SIMPLEX.seed = randi()
	#
	$Player.global_position = Vector2.ZERO
	$Player.connect("MoveEvent", self, "__on_player_MoveEvent")
	__on_player_MoveEvent($Player.global_position)
	#
	$DayNightCycle.connect("HourChangeEvent", self, "__on_hour_changed")

#
# Public
#

func IsEntity (node: Node2D):
	return node is preload("res://Scripts/Extend/Entity.gd")

func GetNavigation ():
	return $Navigation

func GetPlayer ():
	return $Player
	
func SpawnItem (pos, item_data: ItemData):
	pos = AL_Utils.CenterToTilemap($TileMapVisuals, pos)
	var item = preload("res://Scenes/WorldItem.tscn").instance()
	item.position = pos
	item.SetItemData(item_data)
	$ItemController.call_deferred("add_child", item)
	return item

func DropItem (pos, item_data: ItemData):
	SpawnItem(pos, item_data).Drop()
	
func SpawnEntity (pos, entity_data: EntityData):
	var entity = entity_data.GetScene().instance()
	entity.position = pos
	entity.SetEntityData(entity_data)
	$Entities.add_child(entity)
	return entity
