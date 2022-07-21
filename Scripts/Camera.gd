extends Camera2D

export var __MIN_ZOOM = 50
export var __MAX_ZOOM = 0.1
export var __ZOOM_FACTOR = 0.1
export var __ZOOM_LERP_WEIGHT = 0.1
export var __RETURN_LERP_WEIGHT = 0.05
export var __REACH = 3 # lower = closer

onready var __ORG_ITEM_TOOLTIP_SCALE = AL_Game.ItemTooltip.scale
onready var __new_zoom = zoom.x

func _unhandled_input(ev):
	if ev.is_action_pressed("zoom_in"):
		__new_zoom -= __ZOOM_FACTOR
	elif ev.is_action_pressed("zoom_out"):
		__new_zoom += __ZOOM_FACTOR

func _process (delta):
	if Input.is_key_pressed(KEY_CONTROL):
		var new_offset = (get_global_mouse_position() - get_camera_screen_center()) / __REACH
		offset = lerp(offset, new_offset, __ZOOM_LERP_WEIGHT)
	else:
		offset = lerp(offset, Vector2.ZERO, __RETURN_LERP_WEIGHT)
	#
	#
	__new_zoom = clamp(__new_zoom, __MAX_ZOOM, __MIN_ZOOM)
	zoom.x = lerp(zoom.x, __new_zoom, __ZOOM_LERP_WEIGHT)
	zoom.y = zoom.x
	#
	#
	AL_Game.ItemTooltip.scale = __ORG_ITEM_TOOLTIP_SCALE * zoom
