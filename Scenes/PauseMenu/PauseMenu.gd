extends CanvasLayer

export var friendlyfirepath : NodePath
export var teamlistpath : NodePath
export var teamlayoutpath : PackedScene
export var teamnamepath : NodePath

onready var friendlyFire = get_node(friendlyfirepath)
onready var teamList = get_node(teamlistpath)
onready var teamNameEdit = get_node(teamnamepath)
onready var visibility = $Visibility

func _on_CheckButton_toggled(button_pressed : bool) -> void:
	G.rpc("setFriendlyFire", button_pressed)

var changedTeam := false

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		visibility.visible = !visibility.visible
		G.currentPlayer.set_process_input(!visibility.visible)
		
# Start hide myself
# input false
# when game starts input true
func _ready():
	visibility.hide()
	set_process_input(false)
	createTeam("FFA")
	for pid in G.players:
		if G.getTeam(pid) == 0:
			pass

# Update backend AND GUI
remotesync func ct(teamIndex : int):
	var senderId = get_tree().get_rpc_sender_id()
	# update backend
	G.setTeam(senderId, teamIndex)
#	for child in get_tree().get_root().get_children():
#		print(child.name)
#	for child in G.game.get_children():
#		print(child.name)
	var player : Player = G.game.get_node(str(senderId))
	G.chooseTeam(player.hitbox)
	
	# GUI
	var label: Label = player.teamLabel
	label.get_parent().remove_child(label)
	teamList.get_child(teamIndex).addPlayer(label)

# Send over request to change team
func changeTeam(teamIndex : int):
	G.currentTeam = teamIndex
	rpc("ct", teamIndex)

# Creates a new team by creating a new gui and connecting signals
# Team indexs are stored by position in the teamList node
remotesync func createTeam(teamName : String) -> void:
	var newTeam : TeamLayout = teamlayoutpath.instance()
	teamList.add_child(newTeam)
#		print(newTeam.button.text)
#		print(teamNameEdit.text)
	newTeam.button.text = teamName
	newTeam.button.name = str(teamList.get_child_count() - 1)
	G.teamNames.append(teamName)
	newTeam.connect("changeTeam", self, "changeTeam")

# Run new team when a team button is pressed
#func _on_NewTeam_pressed():
#	if len(teamNameEdit.text) > 0:
#		rpc("createTeam", teamNameEdit.text)


func _on_NewTeam_button_up():
	if len(teamNameEdit.text) > 0:
		rpc("createTeam", teamNameEdit.text)
