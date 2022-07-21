extends CanvasModulate
signal HourChangeEvent

export var __1_HOUR_SECONDS = 10.0
export var __hour = 12
const __ANIM_NAME = "cycle"

func __on_hour_passed ():
	__hour += 1
	__hour %= int($AnimationPlayer.get_animation(__ANIM_NAME).length)
	emit_signal("HourChangeEvent", __hour)

func _ready ():
	$Timer.wait_time = __1_HOUR_SECONDS
	$Timer.connect("timeout", self, "__on_hour_passed")
	$Timer.start()
	$AnimationPlayer.playback_speed = 1.0 / __1_HOUR_SECONDS
	$AnimationPlayer.play(__ANIM_NAME)
	$AnimationPlayer.seek(__hour)
