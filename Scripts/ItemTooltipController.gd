extends Node

func _enter_tree ():
	AL_Game.ItemTooltipController = self
	
#
# Public
#

func Hide (item_tooltip):
	item_tooltip.visible = false
	
func Show (item_tooltip, position, item_data: ItemData):
	if not item_tooltip.visible:
		item_tooltip.visible = true
		item_tooltip.SetPosition(position)
		item_tooltip.SetName(item_data.GetName())
		item_tooltip.SetDescription(item_data.GetDescription())

func HandleInput (item_tooltip, position, item_data: ItemData):
	if Input.is_key_pressed(KEY_ALT):
		Show(item_tooltip, position, item_data)
	else:
		Hide(item_tooltip)
