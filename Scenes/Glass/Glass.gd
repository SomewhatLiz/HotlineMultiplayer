extends StaticBody2D
class_name Glass

func playAni() -> void:
	#TODO: Find an animation or make on
	$Sprite.texture = load("res://Art/Environment/Walls/sprGlassPanelBrokenV.png")

func breakWindow() -> void:
	playAni()
	set_collision_mask_bit(3, false)
	set_collision_mask_bit(4, false)
