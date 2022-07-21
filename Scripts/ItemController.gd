extends Node2D
signal MousePressed

func _enter_tree ():
	AL_Game.ItemController = self
