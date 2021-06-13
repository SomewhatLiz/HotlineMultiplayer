extends CanvasLayer

export var ammoPath : NodePath
onready var ammoCount = get_node(ammoPath)

export var healthPath : NodePath
onready var healthBar = get_node(healthPath)

export var killfeedPath : NodePath
onready var killfeed = get_node(killfeedPath)

func _ready():
	var player = get_node("../..")
#	healthBar.max_value = player.MAX_HEALTH



func _on_Timer_timeout():
	pass # Replace with function body.
