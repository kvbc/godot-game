extends "res://Scripts/Extend/Entity.gd"
signal MoveEvent

const ROT_WEIGHT = 0.5
export var __REACH = 50

var __dragging_item
var __from_item_slot
var __from_item_data
var __from_craftinglist = false
var __from_craftingrecipe = []
var __inventory = {}

func __is_dragging_item ():
	return AL_Game.GUI_ItemDragging.GetTexture() != null

func __clamp_position_to_reach (pos):
	if position.distance_to(pos) < __REACH:
		return pos
	return position + position.direction_to(pos) * __REACH

###############################################################################
#
# CraftingList
#
###############################################################################

func __craftinglist_update ():
	AL_Game.CraftingList.SetItemDatas(AL_Game.GetCraftableItemDatasFromItemDatas(__inventory.values()))

func __on_CraftingListItemSlot_mouse_event (itemslot, pressed):
	var itemdata = itemslot.GetItemData()
	if pressed:
		AL_Game.GUI_ItemDragging.SetTexture(itemdata.GetTexture())
		__from_item_slot = itemslot
		__from_item_data = itemdata
		__from_craftingrecipe = itemdata.GetCraftingRecipe()
		__from_item_slot.SetItemData(ItemData.new())
		__from_craftinglist = true
	elif __from_craftinglist:
		AL_Game.GUI_ItemDragging.SetTexture(null)
		__from_item_slot.SetItemData(__from_item_data)
		__from_item_slot = null
		__from_craftinglist = false

###############################################################################
#
# Inventory
#
###############################################################################

func __inventory_update (itemslot):
	__inventory[itemslot] = itemslot.GetItemData()

func __inventory_get (itemslot):
	return __inventory.get(itemslot, ItemData.new())

func __inventory_subtract_ItemDatas (item_data_arr):
	for itemdata in item_data_arr:
		if not itemdata.IsEmpty():
			var q_itemdata = itemdata.GetQuantity()
			for inv_itemslot in __inventory.keys():
				if q_itemdata <= 0:
					break
				var inv_itemdata = __inventory[inv_itemslot]
				if not inv_itemdata.IsEmpty():
					if inv_itemdata.IsSameTypeAs(itemdata):
						var q_inv = inv_itemdata.GetQuantity()
						inv_itemdata.SetQuantity(max(0, q_inv - q_itemdata))
						q_itemdata -= q_inv
						inv_itemslot.SetItemData(inv_itemdata)
						__inventory_update(inv_itemslot)

func __ItemSlot_add_item_data (itemslot, new_itemdata: ItemData):
	var itemdata = itemslot.GetItemData()
	var q1 = itemdata.GetQuantity()
	var q2 = new_itemdata.GetQuantity()
	itemslot.SetItemData(ItemData.new(new_itemdata.GetType(), q1 + q2))
	__inventory_update(itemslot)

# from World
func __on_WorldItem_mouse_pressed (item):
	item.visible = false
	__dragging_item = item
	AL_Game.GUI_ItemDragging.SetTexture(item.GetItemData().GetTexture())

func __on_ItemSlot_mouse_event (itemslot, pressed):
	var itemdata = itemslot.GetItemData()
	if pressed:
		if not itemdata.IsEmpty():
			# from item slot
			AL_Game.GUI_ItemDragging.SetTexture(itemdata.GetTexture())
			__from_item_slot = itemslot
			__from_item_data = itemdata
			__from_item_slot.SetItemData(ItemData.new())
			__inventory_update(__from_item_slot)
	elif __is_dragging_item():
		# from ItemSlot to ItemSlot
		if __from_item_slot != null:
			if __from_craftinglist:
				__inventory_subtract_ItemDatas(__from_craftingrecipe)
			if __from_craftinglist or itemdata.IsSameTypeAs(__from_item_data):
				__ItemSlot_add_item_data(itemslot, __from_item_data)
			else: # Swap
				__from_item_slot.SetItemData(itemdata)
				itemslot.SetItemData(__from_item_data)
				__inventory_update(itemslot)
				__inventory_update(__from_item_slot)
		# from World to ItemSlot
		elif __dragging_item != null:
			if itemdata.IsSameTypeAs(__dragging_item.GetItemData()):
				__ItemSlot_add_item_data(itemslot, __dragging_item.GetItemData())
			else: # Swap
				var prev_item_data = __inventory_get(itemslot)
				itemslot.SetItemData(__dragging_item.GetItemData())
				__inventory_update(itemslot)
				if prev_item_data.IsEmpty():
					__dragging_item.queue_free()
				else:
					__dragging_item.SetItemData(prev_item_data)
					__dragging_item.visible = true
		__dragging_item = null
		__from_item_slot = null
		__from_craftinglist = false
		AL_Game.GUI_ItemDragging.SetTexture(null)
		__craftinglist_update()

func __on_mouse_release_ItemSlot ():
	if __is_dragging_item() and not AL_Game.InventoryItemSlotController.IsMouseOnAnyItemSlot():
		if __dragging_item == null:
			if __from_item_slot != null:
				# from ItemSlot to World
				if __from_craftinglist:
					__inventory_subtract_ItemDatas(__from_craftingrecipe)
				AL_Game.GameWorld.SpawnItem(
					__clamp_position_to_reach(get_global_mouse_position()),
					__from_item_data
				)
				__craftinglist_update()
		else:
			# from World to World
			__dragging_item.global_position = __clamp_position_to_reach(get_global_mouse_position())
			__dragging_item.visible = true
		__dragging_item = null
		__from_item_slot = null
		__from_craftinglist = false
		AL_Game.GUI_ItemDragging.SetTexture(null)

###############################################################################
#
#
#
###############################################################################
			
func __on_hand_body_entered (body):
	if $Hand.IsPunching:
		if body != self and AL_Game.GameWorld.IsEntity(body):
			body.GetEntityData().Damage(GetEntityData().GetBaseDamage())
	
func __move (dir: Vector2, delta):
	move_and_collide(dir * GetEntityData().GetMoveSpeed() * delta)
	emit_signal("MoveEvent", global_position)
	
func _ready ():
	SetEntityData(EntityData.new("player"))
	AL_Game.ItemController.connect("MousePressed", self, "__on_WorldItem_mouse_pressed")
	AL_Game.InventoryItemSlotController.connect("MouseEvent", self, "__on_ItemSlot_mouse_event")
	AL_Game.CraftingListItemSlotController.connect("MouseEvent", self, "__on_CraftingListItemSlot_mouse_event")
	$Hand/Area2D.connect("body_entered", self, "__on_hand_body_entered")

func _input (ev):
	if ev is InputEventMouseMotion:
		AL_Game.GUI_ItemDragging.rect_global_position = get_viewport().get_mouse_position()
	elif ev is InputEventMouseButton and ev.button_index == BUTTON_LEFT:
		if ev.pressed:
			$Hand.Punch()
		else:
			$Hand.Depunch()
			__on_mouse_release_ItemSlot()

func _process(delta):
	rotation = lerp_angle(rotation, global_position.direction_to(get_global_mouse_position()).angle(), ROT_WEIGHT)
	
	if Input.is_key_pressed(KEY_W): __move(Vector2.UP, delta)
	if Input.is_key_pressed(KEY_S): __move(Vector2.DOWN, delta)
	if Input.is_key_pressed(KEY_A): __move(Vector2.LEFT, delta)
	if Input.is_key_pressed(KEY_D): __move(Vector2.RIGHT, delta)
