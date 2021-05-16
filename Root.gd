extends Control

export var gamepath : NodePath
onready var game := get_node(gamepath)

export var menupath : NodePath
onready var menu := get_node(menupath)

export var namepath : NodePath
onready var pname := get_node(namepath)

export var camerapath : NodePath
onready var camera : Camera2D = get_node(camerapath)

export var parallaxpath : NodePath
onready var parallax : ParallaxBackground = get_node(parallaxpath)

onready var timer = $Timer

export var cameraSpeed : float

var lastBgColor = Color(0, 0, 0)

#var tween := Tween.new()
onready var tween := $Tween

#TODO: Add glass to conference room

var colors = [
	"#ff71ce",
	"#01cdfe",
	"#05ffa1",
	"#b967ff",
	"#fffb96"
]

func _ready():
#	add_child(tween)
	menu.show()
	game.hide()
	_on_Timer_timeout()

func _on_Host_pressed():
	isStarting()
	game.host()


func _on_Join_pressed():
	isStarting()
	game.join()

func isStarting(starting := true):
	# startGame runs before networking
	queue_free()
	hide()
	if starting:
		timer.wait_time = 10
	else: 
		timer.wait_time = 5
	PauseMenu.set_process_input(starting)
	menu.visible = !starting
	enableParallax(!starting)
	game.playerName = pname.text 
	game.visible = starting

func _physics_process(delta):
	camera.position.x += cameraSpeed

func getColor(i) -> Color:
	return Color(colors[i % colors.size()])

func _on_Timer_timeout():
	
	var i = randi()
	var bgColor = getColor(i)
	var paraColor = getColor(i + 1)
	var variation := 0.0
	for child in parallax.get_children():
		variation += 0.05
		var addon = Color(variation, variation, variation, 0)
		tween.interpolate_property(child, "modulate", child.modulate, paraColor + addon, timer.wait_time)
	tween.interpolate_method(VisualServer, "set_default_clear_color", lastBgColor, bgColor, timer.wait_time)
	lastBgColor = bgColor
	tween.start()

func enableParallax(visibility := true):
	for child in parallax.get_children():
		child.visible = visibility

