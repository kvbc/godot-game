extends Node2D

export var __CHUNK_SIZE = Vector2(128, 128)
export var __SIMPLEX: OpenSimplexNoise = OpenSimplexNoise.new()
var __tile_weight = {}
var __agent_tiles = {}
var __old_weights = {}
	
#  ██     ██  ██████  ██████  ██      ██████  
#  ██     ██ ██    ██ ██   ██ ██      ██   ██ 
#  ██  █  ██ ██    ██ ██████  ██      ██   ██ 
#  ██ ███ ██ ██    ██ ██   ██ ██      ██   ██ 
#   ███ ███   ██████  ██   ██ ███████ ██████  

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
			
			var is_water = (noise < -0.1)
			var is_sand  = (noise < 0.0)
			var is_tree  = (randf() < 0.05)
			
			var is_traversable = false

			if is_water:
				AL_Utils.TilemapSetRandomCell($TileMap, pos, "water", "water_waves")
			elif is_sand:
				AL_Utils.TilemapSetRandomCell($TileMap, pos, "sand_1", "sand_2")
				is_traversable = true
			else:
				AL_Utils.TilemapSetRandomCell($TileMap, pos, "grass", "grass_grass")
				if is_tree:
					var tree = SpawnEntity(
						$TileMap.to_global($TileMap.map_to_world(pos)),
						EntityData.new("tree")
					)
				else:
					is_traversable = true
					
			if is_traversable:
				__world_update_tile_navigation(pos)
#		yield(get_tree(), "idle_frame")
			
	var chunk_pos_down = chunk_pos + Vector2.DOWN
	var chunk_pos_right = chunk_pos + Vector2.RIGHT

	if __world_chunk_exists(chunk_pos_down):
		__world_update_chunk_navigation(chunk_pos_down)
	if __world_chunk_exists(chunk_pos_right):
		__world_update_chunk_navigation(chunk_pos_right)
		
#   █████   ██████  ███████ ███    ██ ████████ 
#  ██   ██ ██       ██      ████   ██    ██    
#  ███████ ██   ███ █████   ██ ██  ██    ██    
#  ██   ██ ██    ██ ██      ██  ██ ██    ██    
#  ██   ██  ██████  ███████ ██   ████    ██    

func __agent_id (agent: Object):
	return agent.get_instance_id()

func __agent_world_offset (agent_size):
	return (agent_size / 2.0) * $TileMap.cell_size / 2.0
		
func __agent_is_valid_tile (agent: Object, agent_size, tile_pos):
	if not tile_pos in __tile_weight:
		return false
		
	var agent_id = __agent_id(agent)
	var tile_weight = __tile_weight[tile_pos]
	
	#
	#
	# MAKE IT WORK
	#
	#
	
#	for id in __agent_tiles:
#		var tiles = __agent_tiles[id]
#		if tile_pos in tiles:
#			if id != agent_id:
#				return __old_weights[tile_pos] >= agent_size
	
#	if tile_pos in __agent_tiles.get(agent_id, []):
#		for id in __agent_tiles:
#			if id != agent_id:
#				var tiles = __agent_tiles[id]
#				if tile_pos in tiles:
#					return tile_weight >= agent_size
#
#		return __old_weights[tile_pos] >= agent_size

	if tile_pos in __agent_tiles.get(agent_id, []):
		return __old_weights[tile_pos] >= agent_size
		
	return tile_weight >= agent_size

func __agent_get_tile_neighbours (agent: Object, agent_size, map_pos):
	var neighbours = []

	var left      = map_pos + Vector2.LEFT
	var right     = map_pos + Vector2.RIGHT
	var up        = map_pos + Vector2.UP
	var upleft    = map_pos + Vector2.UP + Vector2.LEFT
	var upright   = map_pos + Vector2.UP + Vector2.RIGHT
	var down      = map_pos + Vector2.DOWN
	var downleft  = map_pos + Vector2.DOWN + Vector2.LEFT
	var downright = map_pos + Vector2.DOWN + Vector2.RIGHT
	
	var v_left      = __agent_is_valid_tile(agent, agent_size, left)
	var v_right     = __agent_is_valid_tile(agent, agent_size, right)
	var v_up        = __agent_is_valid_tile(agent, agent_size, up)
	var v_upleft    = __agent_is_valid_tile(agent, agent_size, upleft)
	var v_upright   = __agent_is_valid_tile(agent, agent_size, upright)
	var v_down      = __agent_is_valid_tile(agent, agent_size, down)
	var v_downleft  = __agent_is_valid_tile(agent, agent_size, downleft)
	var v_downright = __agent_is_valid_tile(agent, agent_size, downright)
	
	if v_left  : neighbours.append(left)
	if v_right : neighbours.append(right)
	if v_up    : neighbours.append(up)
	if v_down  : neighbours.append(down)
	
	# Instead of choosing to walk in a stair-like pattern, walk diagonally
	
	if v_up and v_left  and v_upleft  : neighbours.append(upleft)
	if v_up and v_right and v_upright : neighbours.append(upright)
		
	if v_down and v_left  and v_downleft  : neighbours.append(downleft)
	if v_down and v_right and v_downright : neighbours.append(downright)

	return neighbours
	
func __agent_occupy_tiles (agent: Object, agent_size, pos: Vector2):
	var agent_id = __agent_id(agent)
	
	for occ in __agent_tiles.get(agent_id, []):
#		if occ in __old_weights:
		__tile_weight[occ] = __old_weights[occ]
		__old_weights.erase(occ)
			
	__agent_tiles[agent_id] = []
	
	var map_pos = $TileMap.world_to_map(pos + __agent_world_offset(agent_size))
	var xy_range = range(-agent_size * 2 + 1, agent_size + 1)
	for x in xy_range:
		for y in xy_range:
			var occ = map_pos + Vector2(x, y)
			if __tile_weight.get(occ, 0) != 0:
				var old = occ in __old_weights
				if not old:
					__old_weights[occ] = __tile_weight[occ]
					
				if x >= -agent_size+1 and x <= 0 and y >= -agent_size+1 and y <= 0:
					for tiles in __agent_tiles.values():
						if occ in tiles:
							tiles.erase(occ)
							
					__tile_weight[occ] = 0
					__agent_tiles[agent_id].append(occ)
				elif not old:
					__tile_weight[occ] = max(abs(x), abs(y))
					__agent_tiles[agent_id].append(occ)
		
func __agent_get_path (agent: Object, agent_size, start: Vector2, goal: Vector2):
	var agent_offset = __agent_world_offset(agent_size)
	
	var map_start = $TileMap.world_to_map(start + agent_offset)
	var map_goal = $TileMap.world_to_map(goal)
	
	if map_start == map_goal:
		return []
		
	if map_goal in __old_weights:
		if __old_weights[map_goal] < agent_size:
			return []
	else:
		if __tile_weight[map_goal] < agent_size:
			return []
		
#	if __tile_weight.get(map_goal, 0) < agent_size:
#		var new_goal = null
#		for x in range(-agent_size, agent_size + 1):
#			var br = false
#			for y in range(-agent_size, agent_size + 1):
#				var pos = map_goal + Vector2(x, y)
#				if __tile_weight.get(pos, 0) >= agent_size:
#					new_goal = pos
#					br = true
#					break
#			if br: break
#		if new_goal == null:
#			return []
#		map_goal = new_goal
	
	var closed = []
	var open = {
		map_start: {
			"pos": map_start,
			"g": 0,
			"f": null,
			"parent": null
		}
	}
	var q = open[map_start]
	
	while true:
		if q.pos == map_goal:
			var path = []
			while true:
				path.append(AL_Utils.TilemapMapToWorldCentered($TileMap, q.pos) - agent_offset)
				q = q.parent
				if q == null:
					break
			path.invert()
			return path
		
		open.erase(q.pos)
		closed.append(q.pos)
		
		for n in __agent_get_tile_neighbours(agent, agent_size, q.pos):
			if not n in closed:
				var g = q.g + 1
				var h = n.distance_squared_to(map_goal)
				var f = g + h
				
				var open_up = false
				
				if n in open:
					open_up = f < open[n].f
				else:
					open_up = __agent_is_valid_tile(agent, agent_size, n)
					
				if open_up:
					open[n] = {
						"pos": n,
						"g": g,
						"f": f,
						"parent": q
					}
				
		if open.empty():
			break
			
		if open.size() > 50:
			break
		
		q = open.values()[0]
		for o in open.values():
			if o.f < q.f:
				q = o
					
	return []
		
#  ██████  ██████  ██ ██    ██  █████  ████████ ███████ 
#  ██   ██ ██   ██ ██ ██    ██ ██   ██    ██    ██      
#  ██████  ██████  ██ ██    ██ ███████    ██    █████   
#  ██      ██   ██ ██  ██  ██  ██   ██    ██    ██      
#  ██      ██   ██ ██   ████   ██   ██    ██    ███████ 

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

#  ██████  ██    ██ ██████  ██      ██  ██████ 
#  ██   ██ ██    ██ ██   ██ ██      ██ ██      
#  ██████  ██    ██ ██████  ██      ██ ██      
#  ██      ██    ██ ██   ██ ██      ██ ██      
#  ██       ██████  ██████  ███████ ██  ██████ 

func IsEntity (node: Node2D):
	return node is preload("res://Scripts/Extend/Entity.gd")

func GetPlayer ():
	return $Player
	
func AgentOccupyTiles (agent: Object, agent_size, pos: Vector2):
	__agent_occupy_tiles(agent, agent_size, pos)
				
func AgentGetPath (agent: Object, agent_size, start: Vector2, goal: Vector2):
	return __agent_get_path(agent, agent_size, start, goal)
	
func SpawnItem (pos, item_data: ItemData):
	pos = AL_Utils.TilemapWorldCentered($TileMap, pos)
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
