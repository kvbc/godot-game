extends Node2D

export var __DROP_VELOCITY = Vector2(50, -100)
export var __DROP_GRAVITY = Vector2(0, 20)

var __item_data = ItemData.new()
var __velocity = Vector2.ZERO

onready var __ORG_POS = position

#
# Tooltip
#

func __hide_tooltip ():
	AL_Game.ItemTooltipController.Hide(AL_Game.ItemTooltip)

func __update_tooltip ():
	AL_Game.ItemTooltipController.HandleInput(AL_Game.ItemTooltip, position, __item_data)

#
# Item
#

func _input (ev):
	if $Sprite/Area.is_hovered():
		__update_tooltip()

func __on_button_up ():
	__on_mouse_exited()

func __on_button_down ():
	AL_Game.ItemController.emit_signal("MousePressed", self)

func __on_mouse_entered ():
	__update_tooltip()
	$Sprite.material = preload("res://Shaders/Outline.tres")

func __on_mouse_exited ():
	__hide_tooltip()
	$Sprite.material = null

func _ready ():
	$Sprite/Area.connect("button_up", self, "__on_button_up")
	$Sprite/Area.connect("button_down", self, "__on_button_down")
	$Sprite/Area.connect("mouse_entered", self, "__on_mouse_entered")
	$Sprite/Area.connect("mouse_exited", self, "__on_mouse_exited")

func _process (delta):
	if __velocity != Vector2.ZERO:
		__velocity += __DROP_GRAVITY
		position += __velocity * delta
		if position.y >= __ORG_POS.y:
			__velocity = Vector2.ZERO
#
# Public
#

func GetItemData ():
	return __item_data

func SetItemData (item_data: ItemData = __item_data):
	__item_data = item_data
	$Sprite.texture = item_data.GetTexture()

func Drop ():
	__velocity = __DROP_VELOCITY
	__velocity.x *= AL_Utils.RandSign()
