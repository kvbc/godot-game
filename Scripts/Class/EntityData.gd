extends Node
signal DamageTakenEvent
signal DeathEvent
class_name EntityData

var __type
var __health
	
func _init (type = "", health = 0):
	__type = type
	__health = health
	if IsDead():
		__health = GetMaxHealth()

#
#
#

func IsDead ():
	return __health <= 0
	
func IsSameTypeAs (item_data):
	return __type == item_data.GetType()

func Damage (dmg):
	__health -= dmg
	emit_signal("DamageTakenEvent")
	if IsDead():
		emit_signal("DeathEvent")

func Set (entity_data):
	__type = entity_data.GetType()
	SetHealth(entity_data.GetHealth())

#
#
#
	
func GetType ():
	return __type
	
func GetHealth ():
	return __health
	
func SetHealth (health):
	__health = health
	
func GetScene ():
	return AL_Game.GetEntityScene(__type)
	
func GetMaxHealth ():
	return AL_Game.GetEntityMaxHealth(__type)
	
func GetMoveSpeed ():
	return AL_Game.GetEntityMoveSpeed(__type)

func GetBaseDamage ():
	return AL_Game.GetEntityBaseDamage(__type)
