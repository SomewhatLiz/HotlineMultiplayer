extends Node

const ENEMY := "E"
const ITEM := "I"
const PLAYER := "P"
const BULLET := "B"
const PLAYER_HITBOX := "H"

const SHOTGUN := "shotgun"
const MAGNUM := "magnum"

var rng := RandomNumberGenerator.new()
var players := {}
# Players is a dictonary of lists containing each players info
# players[pid] -> [teamNumber, playerName]


var currentPlayer : KinematicBody2D
var teamNames := ["FFA"]
# Team names stored as indices on the list
# example teamNames[0] -> "FFA"

var friendlyFire := false
func _ready():
	rng.seed = 0

onready var game = get_node("/root/Main/Game")

var weapons := {
				none = {path = preload("res://Art/Player/sprPWalkUnarmed_strip8.png"),
						offset = Vector2(0, 0),
						dmg = 0,
						ammo = 0,
						sound = 0,
						fireRate = 0,
						spread = 0,
						pelletCount = 0,
						aniLength = 1,
						itemPath = null,
						weaponName = "none",
						muzzle = Vector2(22, 2),
						deathStrip = null
						},
				SHOTGUN : {path = preload("res://Art/Player/sprPWalkShotgun_strip8.png"),
						offset = Vector2(0, 0),
						dmg = 16,
						ammo = 6,
						sound = 0,
						fireRate = 1,
						spread = 20,
						pelletCount = 8,
						aniLength = 1,
						itemPath = preload("res://Art/Items/image_part_004.png"),
						weaponName = "shotgun",
						muzzle = Vector2(22, 2),
						deathStrip = preload("res://Art/Player/sprPBackShotgun2_strip6.png")
						},
				MAGNUM : {path = preload("res://Art/Player/sprPWalkMagnum_strip8.png"),
						offset = Vector2(6.8, 0.76),
						dmg = 8,
						ammo = 6,  
						sound = 0,
						fireRate = 0.5,
						spread = 3,
						pelletCount = 1,
						aniLength = 1,
						itemPath = preload("res://Art/Items/image_part_003.png"),
						weaponName = "magnum",
						muzzle = Vector2(19, -0.5) + Vector2(6.8, 0.76),
						deathStrip = preload("res://Art/Player/sprPBackShotgun_strip4.png")
						}
				}

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


