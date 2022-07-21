extends Node
signal MouseEnterExitEvent
signal MouseEvent

func _enter_tree ():
	AL_Game.CraftingListItemSlotController = self
