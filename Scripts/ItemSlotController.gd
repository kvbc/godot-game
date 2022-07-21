extends Node
signal MouseEnterExitEvent
signal MouseEvent

func IsMouseOnAnyItemSlot ():
	for itemslot in get_tree().get_nodes_in_group("item_slots"):
		if itemslot is preload("res://Scripts/ActiveItemSlot.gd"):
			if AL_Utils.IsMouseOnControl(itemslot):
				return true
	return false

func _enter_tree ():
	AL_Game.InventoryItemSlotController = self

