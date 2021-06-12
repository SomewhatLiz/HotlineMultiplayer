extends StaticBody2D
class_name Glass

var broken := false

func playAni() -> void:
	#TODO: Find an animation or make on
	$Sprite.texture = load("res://Art/Environment/Walls/sprGlassPanelBrokenV.png")

func flipSprite():
	$Sprite.flip_v = true

func breakWindow() -> void:
	print("broke the window")
	broken = true
	playAni()
	$Hitbox.set_deferred("disabled", true)
#	$Hitbox.disabled = true
#	set_collision_mask_bit(3, false)
#	set_collision_mask_bit(4, false)
#	set_collision_layer_bit(2, false)
