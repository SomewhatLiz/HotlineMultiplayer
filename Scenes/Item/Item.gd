extends KinematicBody2D
class_name Item

onready var sprite := $Sprite

export var weaponName := "none"
var player : KinematicBody2D
var mousedOver := false
var nearPlayer := false

var damping : float = 120

var beingThrown = true

export var rotateSpeed := 10.0

export var ammoCount := 0

var vel := Vector2(200, 0)
#vel

func _ready():
	sprite.texture = G.weapons[weaponName]["itemPath"]
	input_pickable = true
	add_to_group(G.ITEM)

remotesync func removeItem():
	queue_free()

func _physics_process(delta):
#	print("picable ", input_pickable)
	if beingThrown:
		vel -= vel.normalized() * delta * damping
		rotation += deg2rad(rotateSpeed)
		rotateSpeed -= rotateSpeed/50
	if vel.length_squared() <= 1:
		beingThrown = false
	move_and_slide(vel* damping * delta)

func _on_Item_mouse_entered():
	mousedOver = true

func _on_Item_mouse_exited():
	mousedOver = false
		


func _on_RotateCheck_body_entered(body):
	if not body.is_in_group(G.PLAYER):
		rotateSpeed = 0
	pass
