
extends Control
var __item_data = ItemData.new()
var __is_mouse_hovering = false
var __has_mouse_just_entered = false
var __has_mouse_just_exited = false
onready var __ORG_MIN_SIZE = rect_min_size

#
# Tooltip
#

func __hide_tooltip ():
	AL_Game.ItemTooltipController.Hide(AL_Game.GUI_ItemTooltip)

func __update_tooltip ():
	var tooltip = AL_Game.GUI_ItemTooltip
	AL_Game.ItemTooltipController.HandleInput(
		tooltip,
		rect_global_position - Vector2(tooltip.GetSize().x, 0),
		__item_data
	)

#
#
#

func _input (ev):
	if AL_Utils.IsMouseOnControl(self):
		__update_tooltip()
		if not __is_mouse_hovering:
			__has_mouse_just_entered = true
			__is_mouse_hovering = true
		else:
			__has_mouse_just_entered = false
	elif __is_mouse_hovering:
		__hide_tooltip()
		if __is_mouse_hovering:
			__has_mouse_just_exited = true
			__is_mouse_hovering = false
		else:
			__has_mouse_just_exited = false

#
# Public
#

func Highlight ():
	$Control/Slot.texture = preload("res://Assets/slot_active.png")
	
func Unhighlight ():
	$Control/Slot.texture = preload("res://Assets/slot.png")

func Scale (by):
	rect_min_size = __ORG_MIN_SIZE * by
	
func GetItemData ():
	return __item_data
	
func SetItemData (item_data: ItemData = __item_data):
	__item_data = item_data
	$Control/Item.texture = item_data.GetTexture()
	var quantity = item_data.GetQuantity()
	if quantity == 0:
		quantity = ""
	$Control/Quantity.text = String(quantity)
