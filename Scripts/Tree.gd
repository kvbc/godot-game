extends "res://Scripts/Extend/Entity.gd"

func __set_texture (txt):
	$top.texture = txt
	$bot.texture = txt

func __on_EntityData_DamageTakenEvent ():
	if GetEntityData().IsDead():
		AL_Game.GameWorld.DropItem(position, ItemData.new("wood", randi() % 5 + 1))
	elif GetEntityData().GetHealth() <= GetEntityData().GetMaxHealth() * 0.33:
		__set_texture(preload("res://Assets/tree_3.png"))
	elif GetEntityData().GetHealth() <= GetEntityData().GetMaxHealth() * 0.66:
		__set_texture(preload("res://Assets/tree_2.png"))

func _ready ():
	GetEntityData().connect("DamageTakenEvent", self, "__on_EntityData_DamageTakenEvent")
