extends Node

const ENEMY := "E"
const ITEM := "I"
const PLAYER := "P"
const BULLET := "B"
const PLAYER_HITBOX := "H"

const NONE := "none"
const SHOTGUN := "shotgun"
const MAGNUM := "magnum"
const RIFLE := "rifle"

var rng := RandomNumberGenerator.new()
var players := {}
# Players is a dictonary of lists containing each players info
# players[pid] -> [teamNumber, playerName]

var currentPlayer : KinematicBody2D
var teamNames := ["FFA"]
# Team names stored as indices on the list
# example teamNames[0] -> "FFA"

var weapons := {
				NONE : preload("res://Scenes/Item/None.tscn").instance(),
				SHOTGUN : preload("res://Scenes/Item/Shotgun.tscn").instance(),
				MAGNUM : preload("res://Scenes/Item/Magnum.tscn").instance(),
				RIFLE : preload("res://Scenes/Item/Rifle.tscn").instance()
				}

var friendlyFire := false
func _ready():
	rng.seed = 0
	for weapon in weapons:
		add_child(weapons[weapon])
		weapons[weapon].hide()

onready var game = get_node("/root/Main/Game")

remotesync func setFriendlyFire(enabled : bool):
	friendlyFire = enabled
	for player in get_tree().get_nodes_in_group(PLAYER):
		player.chooseTeam()
	PauseMenu.friendlyFire.pressed = enabled

#Get a players team via ID
# getTeam(1) -> 0 (freeForAll)
func getTeam(playerId : int) -> int:
	return players[playerId][0]

func setTeam(playerId: int, teamIndex) -> void:
	players[playerId][0] = teamIndex
#	assert(setTeam() == 3)

# 2 collision layers
# G.currentTeam
# Players dict
func chooseTeam(toChange : CollisionObject2D, isbullet : bool = false):
	var team = G.getTeam(toChange.get_network_master())
	var ffa : bool = G.currentTeam == 0
	if not isbullet:
#		toChange.set_collision_layer_bit(3, ffa or G.currentTeam != team) # true
#		toChange.set_collision_layer_bit(4, ffa or G.currentTeam == team) # false
		toChange.set_collision_mask_bit(3, ffa or G.currentTeam != team) # true
		toChange.set_collision_mask_bit(4, ffa or G.currentTeam == team) # false
	else:
		toChange.set_collision_layer_bit(3, ffa or G.currentTeam == team) # true
		toChange.set_collision_layer_bit(4, ffa or G.currentTeam != team) # false

func getName(playerId: int) -> String:
	return players[playerId][1]

var currentTeam := 0


