extends VBoxContainer

func _ready ():
	$GridContainer.columns = AL_Game.InventoryCols
	for i in AL_Game.InventorySlots:
		var slot = preload("res://Scenes/ActiveItemSlot.tscn").instance()
		slot.HighlightOnHover = true
		slot.Controller = AL_Game.InventoryItemSlotController
		$GridContainer.add_child(slot)
