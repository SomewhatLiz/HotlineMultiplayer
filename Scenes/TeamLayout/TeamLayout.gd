extends VBoxContainer
class_name TeamLayout

signal changeTeam

onready var button := $TeamNameButton
onready var playerList := $HBoxContainer/PlayerNames

func addPlayer(label : Label):
	playerList.add_child(label)


func _on_TeamNameButton_pressed():
	emit_signal("changeTeam", int(button.name))
	# index : name
