extends "res://Scripts/Extend/Entity.gd"

export var __AGENT_SIZE = 2
export var __ROTATION_LERP_WEIGHT = 0.1

onready var __player = AL_Game.GameWorld.GetPlayer()
var __safe_velocity = Vector2.ZERO
onready var __next_pos = global_position
var path = []
var i = 0

func _physics_process (delta):
#	var path = AL_Game.GameWorld.AgentGetPath(self, __AGENT_SIZE, global_position, __player.global_position)
#	if path.size() >= 2:
#		__next_pos = path[1]
#		move_and_collide(
#			delta * GetEntityData().GetMoveSpeed() *
#			global_position.direction_to(__next_pos)
#		)

	if path.size() <= 1:
		path = AL_Game.GameWorld.AgentGetPath(self, __AGENT_SIZE, global_position, __player.global_position)
	if path.size() >= 2:
		var dir = global_position.direction_to(path[1])
		var collision = move_and_collide(delta * GetEntityData().GetMoveSpeed() * dir)
		if collision or global_position.distance_to(path[1]) < 8:
			path = []

#	if path.empty():
#		i = 0
#		path = AL_Game.GameWorld.AgentGetPath(self, __AGENT_SIZE, global_position, __player.global_position)
#		if path.empty():
#			return
#
#	AL_Game.GameWorld.get_node("DEBUG2").clear_points()
#	for p in path:
#		AL_Game.GameWorld.get_node("DEBUG2").add_point(AL_Game.GameWorld.get_node("DEBUG2").to_local(p))
#
#	var p = path[i]
#	if global_position.distance_to(p) < 10:
#		i += 1
#		if i >= path.size():
#			path = []
#			return
#		p = path[i]
#
#	move_and_collide(
#		delta * GetEntityData().GetMoveSpeed() *
#		global_position.direction_to(p)
#	)
	
func _process (delta):
	rotation = lerp_angle(rotation, global_position.direction_to(__player.global_position).angle(), __ROTATION_LERP_WEIGHT)
	pass

func _ready ():
	AL_Game.GameWorld.AgentRegister(self, __AGENT_SIZE)
	GetEntityData().connect("DeathEvent", self, "call_deferred", ["queue_free"])

#
#
#

func __can_attack ():
	return $AttackArea.overlaps_body(__player)
