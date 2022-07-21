extends CenterContainer

func _enter_tree ():
	AL_Game.GUI_ItemDragging = self

#
# Public
#

func GetTexture ():
	return $TextureRect.texture

func SetTexture (tex):
	$TextureRect.texture = tex
