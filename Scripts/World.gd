extends Node2D

export var __CHUNK_SIZE = Vector2(32, 32)
export var __SIMPLEX: OpenSimplexNoise = OpenSimplexNoise.new()
var __tile_weight = {}
	
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

func __world_chunk_exists (chunk_pos):
	return AL_Utils.TilemapHasCell($TileMap, __world_chunk_to_map(chunk_pos))

func __world_update_tile_navigation (pos):
	__tile_weight[pos] = 1
	var check = pos + Vector2(-1, -1)
	if __tile_weight.has(check):
		var new_weight = __tile_weight[check]
		var max_ofs = new_weight
		for ofs in range(1, new_weight + 1):
			if not __tile_weight.has(pos - Vector2(ofs, 0)):
				max_ofs = ofs - 1
				break
			if not __tile_weight.has(pos - Vector2(0, ofs)):
				max_ofs = ofs - 1
				break
		__tile_weight[pos] += max_ofs

func __world_update_chunk_navigation (chunk_pos):
	var map_pos = __world_chunk_to_map(chunk_pos)
	for x in range(map_pos.x, map_pos.x + __CHUNK_SIZE.x):
		for y in range(map_pos.y, map_pos.y + __CHUNK_SIZE.y):
			var pos = Vector2(x, y)
			if __tile_weight.has(pos):
				__world_update_tile_navigation(pos)

func __world_generate_chunk (chunk_pos):
	randomize()
	
	var map_pos = __world_chunk_to_map(chunk_pos)
	for x in range(map_pos.x, map_pos.x + __CHUNK_SIZE.x):
		for y in range(map_pos.y, map_pos.y + __CHUNK_SIZE.y):
			var pos = Vector2(x, y)
			var noise = __SIMPLEX.get_noise_2d(x, y)
			
			var is_water = (noise < 0.01)
			var is_sand  = (noise < 0.05)
			var is_tree  = (randf() < 0.05)
			var is_traversable = (not is_water and not is_tree)

			if is_water:
				AL_Utils.TilemapSetRandomCell($TileMap, pos, "water", "water_waves")
			elif is_sand:
				AL_Utils.TilemapSetRandomCell($TileMap, pos, "sand_1", "sand_2")
			else:
				AL_Utils.TilemapSetRandomCell($TileMap, pos, "grass", "grass_grass")
				if is_tree:
					var tree = SpawnEntity(
						$TileMap.to_global($TileMap.map_to_world(pos)),
						EntityData.new("tree")
					)
					
			if is_traversable:
				__world_update_tile_navigation(pos)
			
	var chunk_pos_down = chunk_pos + Vector2.DOWN
	var chunk_pos_right = chunk_pos + Vector2.RIGHT

	if __world_chunk_exists(chunk_pos_down):
		__world_update_chunk_navigation(chunk_pos_down)
	if __world_chunk_exists(chunk_pos_right):
		__world_update_chunk_navigation(chunk_pos_right)
						
#
#
#

func __on_player_MoveEvent (pos):
	var plr_chunk_pos = __world_global_to_chunk(pos)
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var chunk_pos = plr_chunk_pos + Vector2(x, y)
			if not __world_chunk_exists(chunk_pos):
				__world_generate_chunk(chunk_pos)
	
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
