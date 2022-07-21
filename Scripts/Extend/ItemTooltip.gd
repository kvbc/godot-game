extends Node

func __on_vbox_resized ():
	$MarginContainer/VBoxContainer/Background.rect_min_size.y = 1 + $MarginContainer/VBoxContainer/Background/VBoxContainer.rect_size.y * $MarginContainer/VBoxContainer/Background/VBoxContainer.rect_scale.y

func _ready ():
	$MarginContainer/VBoxContainer/Background/VBoxContainer.connect("resized", self, "__on_vbox_resized")

#
# Public
#

func SetName (name):
	$MarginContainer/VBoxContainer/Background/VBoxContainer/Name.text = name.capitalize()

func SetDescription (desc):
	$MarginContainer/VBoxContainer/Background/VBoxContainer/Description.text = desc

func GetSize ():
	return $MarginContainer.rect_size * $MarginContainer.rect_scale
