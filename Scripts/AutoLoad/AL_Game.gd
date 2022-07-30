extends Node

const CraftingListSlots = 9
const ToolbarSlots = 9
const InventoryCols = 3
const InventorySlots = 27

var CraftingList: Control
var GameWorld: Node2D
var ItemTooltip: Node
var ItemController: Node2D
var InventoryItemSlotController: Node
var ItemTooltipController: Node
var CraftingListItemSlotController: Node
var GUI: CanvasLayer
var GUI_ItemTooltip: Node
var GUI_ItemDragging: Control
var GUI_CraftingRecipe: Control

var __ENTITIES = {
	player = {
		max_health = 100,
		move_speed = 100,
		base_damage = 35
	},
	zombie = {
		scene = preload("res://Scenes/Entity/Zombie.tscn"),
		max_health = 100,
		move_speed = 70,
		base_damage = 0#10
	},
	tree = {
		scene = preload("res://Scenes/Entity/Tree.tscn"),
		max_health = 100
	}
}

var __ITEMS = {
	wood = {
		name = "wood",
		texture = preload("res://Assets/item/wood.png")
	},
	stick = {
		name = "stick",
		texture = preload("res://Assets/item/stick.png"),
		recipe = [ItemData.new("wood", 1)],
		recipe_quantity = 2
	},
	wooden_sword = {
		name = "wooden sword",
		texture = preload("res://Assets/item/wooden_sword.png"),
		recipe = [ItemData.new("stick", 1), ItemData.new("wood", 3)]
	}
}

#
# Entity
#

func GetEntityMaxHealth (entity_type):
	return __ENTITIES.get(entity_type, {}).get("max_health", null)

func GetEntityScene (entity_type):
	return __ENTITIES.get(entity_type, {}).get("scene", null)

func GetEntityMoveSpeed (entity_type):
	return __ENTITIES.get(entity_type, {}).get("move_speed", null)

func GetEntityBaseDamage (entity_type):
	return __ENTITIES.get(entity_type, {}).get("base_damage", null)

#
# Item
#

func GetItemName (item_type):
	return __ITEMS.get(item_type, {}).get("name", "???")

func GetItemTexture (item_type):
	return __ITEMS.get(item_type, {}).get("texture", null)

func GetItemDescription (item_type):
	return __ITEMS.get(item_type, {}).get("desc", "")

func GetItemCraftingRecipe (item_type):
	return __ITEMS.get(item_type, {}).get("recipe", [])
	
func GetCraftableItemDatasFromItemDatas (item_data_arr):
	var r = []
	for item_type in __ITEMS.keys():
		var item = __ITEMS[item_type]
		if item.has("recipe"):
			var item_types_matching = []
			for itemdata in item.recipe:
				var totalcount = 0
				for given_itemdata in item_data_arr:
					if not item_types_matching.has(given_itemdata.GetType()):
						if itemdata.IsSameTypeAs(given_itemdata):
							totalcount += given_itemdata.GetQuantity()
							if totalcount >= itemdata.GetQuantity():
								item_types_matching.append(given_itemdata.GetType())
								if item_types_matching.size() == item.recipe.size():
									r.append(ItemData.new(item_type, item.get("recipe_quantity", 1)))
	return r
