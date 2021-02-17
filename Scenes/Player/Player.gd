extends KinematicBody2D

var speed := 100
var velocity := Vector2(0, 0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move():

	look_at(get_global_mouse_position())
	velocity = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		)
	
	velocity = move_and_slide(velocity.normalized() * speed)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move()
