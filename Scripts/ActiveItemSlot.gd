extends "res://Scripts/PassiveItemSlot.gd"
signal MouseReleased

var HoverOffset = 0
var HighlightOnHover = false
var Controller = null # A controller is required

var __is_activated = false

#
# Position
#

func __set_pos_hovered ():
	$Control.rect_position.y = -HoverOffset

func __set_pos_normal ():
	$Control.rect_position.y = 0
	
#
# ItemSlot
#

func _input (ev):
	if ev is InputEventMouseMotion:
		if __has_mouse_just_entered or __has_mouse_just_exited:
			Controller.emit_signal("MouseEnterExitEvent", self, __has_mouse_just_entered)
		if AL_Utils.IsMouseOnControl(self):
			__set_pos_hovered()
			if HighlightOnHover:
				Highlight()
		elif not __is_activated:
			__set_pos_normal()
			Unhighlight()
	elif ev is InputEventMouseButton and __is_mouse_hovering and ev.button_index == BUTTON_LEFT:
		if not ev.pressed:
			emit_signal("MouseReleased")
		Controller.emit_signal("MouseEvent", self, ev.pressed)

#
# Public
#

func Activate ():
	__is_activated = true
	__set_pos_hovered()
	Highlight()
	
func Deactivate ():
	__is_activated = false
	__set_pos_normal()
	Unhighlight()
