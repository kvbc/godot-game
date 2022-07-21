extends Control

var __is_hovering = false
var __active_itemslot_idx = null

func _enter_tree ():
	AL_Game.CraftingList = self

func __clear_active_recipe ():
	AL_Utils.RemoveChildren($Recipe/ItemSlots)

func __set_active_itemslot (idx):
	if __active_itemslot_idx != null:
		$ItemSlots.get_child(__active_itemslot_idx).Deactivate()
	__active_itemslot_idx = idx
	
	#
	# TODO: Quite inefficient
	#
	var itemslot = $ItemSlots.get_child(idx)
	itemslot.Activate()
	__clear_active_recipe()
	for itemdata in itemslot.GetItemData().GetCraftingRecipe():
		var slot = preload("res://Scenes/PassiveItemSlot.tscn").instance()
		slot.SetItemData(itemdata)
		$Recipe/ItemSlots.add_child(slot)
		slot.Scale(0.5)
	
	for i in $ItemSlots.get_child_count():
		var slot = $ItemSlots.get_child(i)
		var scale = 1
		if i != idx:
			var dist = abs(i - idx)
			if dist > AL_Game.CraftingListSlots / 2:
				scale = 0
				slot.visible = false
			else:
				slot.visible = true
				scale = (AL_Game.CraftingListSlots - dist) / float(AL_Game.CraftingListSlots)
		slot.Scale(scale)
	
func __on_ItemSlot_MouseEnterExitEvent (itemslot, entered):
	if entered:
		__set_active_itemslot(itemslot.get_index())
		
func _ready ():
	AL_Game.CraftingListItemSlotController.connect("MouseEnterExitEvent", self, "__on_ItemSlot_MouseEnterExitEvent")
		
func _input (ev):
	if ev is InputEventMouseMotion:
		__is_hovering = AL_Utils.IsMouseOnControl(self)
	elif ev is InputEventMouseButton:
		if ev.pressed and __is_hovering:
			if __active_itemslot_idx != null:
				if ev.button_index == BUTTON_WHEEL_UP:
					if __active_itemslot_idx > 0:
						__set_active_itemslot(__active_itemslot_idx - 1)
				elif ev.button_index == BUTTON_WHEEL_DOWN:
					if __active_itemslot_idx < $ItemSlots.get_child_count() - 1:
						__set_active_itemslot(__active_itemslot_idx + 1)
					
#
# Public
#

func SetItemDatas (item_data_arr):
	while $ItemSlots.get_child_count() > item_data_arr.size():
		$ItemSlots.remove_child($ItemSlots.get_children().back())
	for i in item_data_arr.size():
		var itemdata = item_data_arr[i]
		var itemslot = AL_Utils.GetChildOrNull($ItemSlots, i)
		if itemslot == null:
			itemslot = preload("res://Scenes/ActiveItemSlot.tscn").instance()
			itemslot.Controller = AL_Game.CraftingListItemSlotController
			$ItemSlots.add_child(itemslot)
		itemslot.SetItemData(itemdata)
	if __active_itemslot_idx == null:
		__active_itemslot_idx = 0
	if AL_Utils.HasChild($ItemSlots, __active_itemslot_idx):
		__set_active_itemslot(__active_itemslot_idx)
	else:
		__active_itemslot_idx = null
		if $ItemSlots.get_child_count() == 0:
			__clear_active_recipe()
		else:
			__set_active_itemslot($ItemSlots.get_child_count() - 1)
