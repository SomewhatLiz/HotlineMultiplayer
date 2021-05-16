extends CanvasLayer

export var ammoPath : NodePath
onready var ammoCount = get_node(ammoPath)

export var healthPath : NodePath
onready var healthBar = get_node(healthPath)



func _ready():
	var player = get_node("../..")
	healthBar.max_value = player.MAX_HEALTH

