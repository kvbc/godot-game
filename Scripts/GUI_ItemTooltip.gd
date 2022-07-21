extends "res://Scripts/Extend/ItemTooltip.gd"

func SetPosition (pos):
	self.rect_position = pos

func _enter_tree ():
	AL_Game.GUI_ItemTooltip = self
