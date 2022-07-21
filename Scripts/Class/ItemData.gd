extends Node
class_name ItemData

var __type
var __quantity
	
func _init (type = "", quantity = 0):
	__type = type
	__quantity = quantity

#
#
#

func IsEmpty ():
	return __type.empty() || __quantity == 0
	
func IsSameTypeAs (item_data):
	return __type == item_data.GetType()
	
#
#
#
	
func GetType ():
	return __type
	
func GetQuantity ():
	return __quantity
	
func SetQuantity (quantity):
	__quantity = quantity
	
func GetName ():
	return AL_Game.GetItemName(__type)
	
func GetTexture ():
	if IsEmpty():
		return null
	return AL_Game.GetItemTexture(__type)

func GetDescription ():
	return AL_Game.GetItemDescription(__type)

func GetCraftingRecipe ():
	return AL_Game.GetItemCraftingRecipe(__type)
