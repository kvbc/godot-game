extends "res://Scripts/Extend/Enemy.gd"

export var __ATTACK_DAMAGE = 5
export var __ATTACK_LERP_WEIGHT = 0.5
export var __RETURN_LERP_WEIGHT = 0.03
export var __ATTACK_ANGLE = 75.0
export var __ATTACK_ANGLE_CUT = 5.0

var __is_attacking = false

func __damage_body_if_can (body):
	if body != self and AL_Game.GameWorld.IsEntity(body):
		body.GetEntityData().Damage(GetEntityData().GetBaseDamage())

func __on_Hand_BodyEntered (body):
	if __is_attacking:
		__damage_body_if_can(body)

func _ready ():
	$Hand/Area2D.connect("body_entered", self, "__on_Hand_BodyEntered")

func _process (delta):
	if __is_attacking:
		$Hand.rotation_degrees = lerp($Hand.rotation_degrees, __ATTACK_ANGLE, __ATTACK_LERP_WEIGHT)
		if abs($Hand.rotation_degrees - __ATTACK_ANGLE) < __ATTACK_ANGLE_CUT:
			__is_attacking = false
	else:
		$Hand.rotation_degrees = lerp($Hand.rotation_degrees, 0, __RETURN_LERP_WEIGHT)
		if $Hand.rotation_degrees < __ATTACK_ANGLE_CUT:
			if __can_attack():
				__is_attacking = true
				for body in $Hand/Area2D.get_overlapping_bodies():
					__damage_body_if_can(body)
