extends "res://Scripts/Extend/ItemTooltip.gd"

func SetPosition (pos):
	self.position = pos

func _enter_tree ():
	AL_Game.ItemTooltip = self
