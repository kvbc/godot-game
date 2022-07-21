extends Sprite

export var __PUNCH_LERP_WEIGHT = 0.5
export var __DEPUNCH_LERP_WEIGHT = 0.2
export var __PUNCH_SCALE = Vector2(1, 1)

var __lerp_weight = 1
var __new_scale = Vector2(0, 1)

var IsPunching = false

func _process (delta):
	scale = lerp(scale, __new_scale, __lerp_weight)

#
# Public
#

func Punch ():
	IsPunching = true
	__new_scale = __PUNCH_SCALE
	__lerp_weight = __PUNCH_LERP_WEIGHT

func Depunch ():
	IsPunching = false
	__new_scale = Vector2(0, 1)
	__lerp_weight = __DEPUNCH_LERP_WEIGHT
