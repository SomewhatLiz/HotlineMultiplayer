extends Area2D
class_name bullet

var sender : KinematicBody2D
var dmg := 0.0
var vel := Vector2(800, 0)
var penetration := 1
var deathStrip

var splatRes := preload("res://Scenes/Particles/WallSplat.tscn")

func _ready():
	add_to_group(G.BULLET)

func _physics_process(delta):
	position += vel * delta

func _on_Bullet_area_entered(area : Area2D):
	if area.get_parent().is_in_group(G.PLAYER_HITBOX) and area.get_parent().health > 0:
		penetration -= 1
		if penetration < 1:
			print(area.name)
			queue_free()

func _on_Bullet_body_entered(body):
#	print(body.get_children())
	if body is Glass:
		body.breakWindow()
		vel = vel.rotated(PI/6)
	elif body is Player:
		var splat : Particles2D = splatRes.instance()
		splat.global_position = global_position
		splat.rotate(vel.angle() + PI)
		get_parent().add_child(splat)
		splat.emitting = true
		queue_free()
