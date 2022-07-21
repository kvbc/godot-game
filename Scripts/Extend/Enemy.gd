extends "res://Scripts/Extend/Entity.gd"

export var __ROTATION_LERP_WEIGHT = 0.1

onready var __player = AL_Game.GameWorld.GetPlayer()
var __safe_velocity = Vector2.ZERO
onready var __next_pos = global_position

func __on_NavigationAgent_velocity_computed (safe_velocity):
	__safe_velocity = safe_velocity

func _physics_process (delta):
	var collision = move_and_collide(__safe_velocity)
	
#	if global_position.distance_to(__next_pos) < $NavigationAgent2D.path_desired_distance:
	var map = AL_Game.GameWorld.GetNavigation().get_rid()
	var path = Navigation2DServer.map_get_path(map, global_position, __player.global_position, false)
	if path.size() >= 2:
		__next_pos = Navigation2DServer.map_get_closest_point(map, path[1])
			
	$NavigationAgent2D.set_velocity(global_position.direction_to(__next_pos))
	
func _process (delta):
	rotation = lerp_angle(rotation, global_position.direction_to(__player.global_position).angle(), __ROTATION_LERP_WEIGHT)

func _ready ():
	$NavigationAgent2D.connect("velocity_computed", self, "__on_NavigationAgent_velocity_computed")

#
#
#

func __can_attack ():
	return $AttackArea.overlaps_body(__player)
