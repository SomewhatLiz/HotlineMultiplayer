extends Node2D

const PORT = 8070

var playerName : String

var playerRes := load("res://Scenes/Player/Player.tscn")

var _mouse_start: Vector2
var _last_color: int = -1
var _color: int

onready var spawnLocs = $Spawns

#remote var G.players := {}

func host():
	playerName = "Host"
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT)
	get_tree().set_network_peer(peer)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	_player_connected(get_tree().get_network_unique_id())
	print(get_tree().get_network_unique_id())
	print("host")

func join():
	playerName = "Client"
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("127.0.0.1", PORT)
	get_tree().set_network_peer(peer)
	yield(get_tree(), "connected_to_server")
	print(get_tree().get_network_unique_id()) 
	print("join")

# After host/join, only called on host
func _player_connected(id : int):
	print(id)
	# Handle player connecting
	for pid in G.players:
		var playerInfo = G.players[pid]
		print(playerInfo)
		
		# Spawning old guys on our new guy, Get everyone else's names
		#TODO: Refactor getting teams so we dont have to index into the lists 
		rpc_id(id, "register_player", pid, G.getTeam(pid))
	# new guy's id, send his name, team
	rpc("register_player", id, 0)
	# Send our name
	rpc("req_name")

remote func req_name():
	rpc("setName", playerName)

func spawn(id: int):
	var p = playerRes.instance()
	p.name = str(id)
	p.set_network_master(id, true)
	var spawnPos = spawnLocs.get_child(G.rng.randi() % spawnLocs.get_child_count())
	p.position = spawnPos.position 
	
	add_child(p)

remotesync func register_player(id : int, team : int):
	# Sync all G.players
	print("registering ", str(id))
	if not id in G.players:
#		Add player to FFA team when they first join
		G.players[id] = [team, ""]
		spawn(id)
		setNameLocal(id, "")
		# [1] = [0, "aaa"]

remotesync func setName(newPlayerName: String):
	var senderId = get_tree().get_rpc_sender_id()
	print("Set as ", newPlayerName)
	setNameLocal(senderId, newPlayerName)

func setNameLocal(pid : int, newPlayerName : String):
	G.players[pid][1] = newPlayerName
	G.game.get_node(str(pid)).teamLabel.text = newPlayerName


#remote func spawn_player(id : int):
#	# Spawn single player
#	for playerInfo in G.players:
#		rpc_id(id, "spawn", playerInfo)
#	rpc("register_player", id)

func _on_CloseInstructions_clicked(instance):
	$Instructions.hide()
	

