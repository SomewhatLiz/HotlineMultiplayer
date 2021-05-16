extends StaticBody2D
class_name Glass

var broken := false

func playAni() -> void:
	#TODO: Find an animation or make on
	$Sprite.texture = load("res://Art/Environment/Walls/sprGlassPanelBrokenV.png")

func breakWindow() -> void:
	broken = true
	playAni()
	set_collision_mask_bit(3, false)
	set_collision_mask_bit(4, false)
