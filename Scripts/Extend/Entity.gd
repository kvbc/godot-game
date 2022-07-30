extends KinematicBody2D

const ___HITFLASH_DURATION = 0.1 # in seconds

var ___entitydata = EntityData.new()

func ___on_hitflash_end ():
	material = null

func ___on_EntityData_DamageTakenEvent ():
	material = preload("res://Shaders/Hitflash.tres")
	get_tree().create_timer(___HITFLASH_DURATION).connect("timeout", self, "___on_hitflash_end")

func _ready ():
	___entitydata.connect("DamageTakenEvent", self, "___on_EntityData_DamageTakenEvent")

#
# Public
#

func GetEntityData ():
	return ___entitydata
	
func SetEntityData (entity_data: EntityData):
	___entitydata.Set(entity_data)
