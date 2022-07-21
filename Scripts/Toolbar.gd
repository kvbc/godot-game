extends MarginContainer

export var __HOVER_OFFSET = 25
var __cur_slot = null

func __set_slot (slot):
	if slot == __cur_slot:
		slot.Deactivate()
		__cur_slot = null
	else:
		if __cur_slot != null:
			__cur_slot.Deactivate()
		slot.Activate()
		__cur_slot = slot

func _input (ev):
	if not ev is InputEventKey:
		return
	if not ev.pressed:
		return
	if ev.scancode >= KEY_1 and ev.scancode <= KEY_9:
		__set_slot($Rows/Slots.get_child(ev.scancode - KEY_1))

func _ready ():
	for i in AL_Game.ToolbarSlots:
		var slot = preload("res://Scenes/ActiveItemSlot.tscn").instance()
		slot.HoverOffset = __HOVER_OFFSET
		slot.Controller = AL_Game.InventoryItemSlotController
		slot.connect("MouseReleased", self, "__set_slot", [slot])
		$Rows/Slots.add_child(slot)
