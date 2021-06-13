extends KinematicBody2D
class_name Player

onready var sprite := $Sprite
onready var tween := $Tween
onready var muzzle := $Muzzle
onready var hitbox := $HitBox
onready var GUI 
onready var fireTimer := $Firerate
onready var respawnTimer := $Respawn
onready var gunshot := $Gunshot
onready var Game := get_parent()
onready var cam 
onready var light := $light

puppet var pos := Vector2()
puppet var rot := 0.0
#puppet var v := Vector2()

export(String, FILE) var camPath
export(String, FILE) var itemPath
export(String, FILE) var bullPath
export(String, FILE) var deadPath


onready var camRes := load(camPath)
onready var itemRes := load(itemPath)
onready var bullRes := load(bullPath)
onready var deadRes := load(deadPath)

#export(String, FILE) var secen_path
#export (NodePath) var Menu_path

signal killed

var weaponI := 0
var itemsNear := []

remote var ammo := 0
var MAX_HEALTH := 15.0
remote var health := MAX_HEALTH
var speed := 100
remote var vel := Vector2(0, 0)

var regex = RegEx.new()
var dead := false
onready var deadBody = deadRes.instance()

var weapons = G.weapons

var teamLabel := Label.new()

var currentWeapon : Sprite = weapons[G.NONE]

func _ready():
	PauseMenu.teamList.get_child(0).addPlayer(teamLabel)
	if is_network_master():
		$NetworkPos.hide()
		light.enabled = true
		teamLabel.text = G.getName(get_network_master())
		cam = camRes.instance()
		add_child(cam)
		cam.current = true
		GUI = cam.get_node("GUI")
		GUI.healthBar.value = health
		G.currentPlayer = self
		connect("killed", GUI.killfeed, "addDeath")
	else:
		set_process_input(false)
	G.chooseTeam(hitbox)
#	position = Vector2(G.rng.randf(), G.rng.randf()) * 150
#	set_physics_process(false)
	add_to_group(G.PLAYER)
	$HitBox.add_to_group(G.PLAYER_HITBOX)
#	Engine.time_scale = 0.1
	regex.compile("([\\d]+)")
	switchWeapon(G.SHOTGUN, 6)

func _physics_process(delta):
	if not is_network_master() and not dead:
		$NetworkPos.global_position = pos
		position = position.linear_interpolate(pos, 0.5)
		rotation = rot
	elif is_network_master():
		move()
	moveAni()

func _input(event):
	if not dead:
		if Input.is_action_just_pressed("pickup"):
			rpc("throw")
			if len(itemsNear) > 0:
				var wep = itemsNear[0]
				if wep.mousedOver and wep.nearPlayer:
					rpc("switchWeapon", wep["weaponName"], wep.ammoCount)
					# sync up weapon names
					wep.rpc("removeItem")
		if Input.is_action_just_pressed("shoot") and fireTimer.is_stopped() and ammo > 0:
			rset("rot", rotation)
			rpc("shoot")
		vel = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), 
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			)

func getWeaponFrames(weaponName) -> int:
	var path : String = weapons[weaponName].texture.resource_path
	var result = regex.search_all(path)
	return int(result[-1].get_string())

func getFrames(string : String) -> int:
	var result = regex.search_all(string)
	return int(result[-1].get_string())

remotesync func switchWeapon(weaponName := "none", ammoCount := -1):
	currentWeapon = weapons[weaponName]
	sprite.offset = currentWeapon.offset
	sprite.hframes = getWeaponFrames(weaponName)
	sprite.texture = currentWeapon.texture
	print(currentWeapon.muzzle)
	muzzle.position = currentWeapon.muzzle.position
	fireTimer.wait_time = currentWeapon.fireRate
	tween.interpolate_property(sprite, "frame", 0, sprite.hframes - 1, currentWeapon.aniLength)
	if ammoCount < 0:
		ammo = currentWeapon.ammo
	else:
		ammo = ammoCount
	if is_network_master():
		if weaponName == "none":
			GUI.ammoCount.text = " "
		else:
			setAmmo(ammo)
#			GUI.ammoCount.text = str(ammo) + "/" + str(currentWeapon["ammo"])

func move():
	look_at(get_global_mouse_position())
	vel = move_and_slide(vel.normalized() * speed)
	rset("pos", position)
	rset("rot", rotation)
	rset("vel", vel)

func moveAni():
	if vel != Vector2(0, 0):
		tween.resume(sprite, "frame")
	else:
		tween.stop(sprite, "frame")

# "Shoot" res at current look position
func project(res) -> Node2D:
	var newProject = res.instance()
	newProject.vel = newProject.vel.rotated(rotation)
	newProject.global_position = global_position
	return newProject

remotesync func throw():
	if currentWeapon != weapons["none"]:
		weaponI += 1
		var newItem := project(itemRes)
		var oldWeapon = currentWeapon
		newItem.ammoCount = ammo
		newItem.input_pickable = true
		switchWeapon()
		get_parent().add_child(newItem)
		newItem.weaponName = oldWeapon["weaponName"]
		newItem.sprite.texture = oldWeapon["itemPath"]
		newItem.name = name + str(weaponI)

remotesync func shoot():
	gunshot.play()
	for i in range(currentWeapon["pelletCount"]):
		var bullet : Area2D = project(bullRes)
		bullet.sender = self
		bullet.deathStrip = currentWeapon["deathStrip"]
		bullet.dmg = currentWeapon["dmg"]/currentWeapon["pelletCount"]
		var spread := deg2rad(G.rng.randf_range(-currentWeapon["spread"], currentWeapon["spread"]))
		bullet.position = muzzle.global_position
		bullet.vel = bullet.vel.rotated(spread)
		bullet.rotation = bullet.vel.angle()
		# bullet master = curernt netmast
		bullet.set_network_master(get_network_master())
		G.chooseTeam(bullet, true)
		get_parent().add_child(bullet)
	ammo -= 1
	if is_network_master():
		setAmmo(ammo)
	fireTimer.start()

# Resets players position to random spawn location
func respawn():
	switchWeapon(G.MAGNUM)
	dead = false
	var spawnLocs = Game.spawnLocs
	var spawnPos = spawnLocs.get_child(G.rng.randi() % spawnLocs.get_child_count())
	position = spawnPos.position 
	visible = true

func setHealth(hp):
	GUI.healthBar.value = hp
	health = hp
	if is_network_master():
		rset("health", health)

func setAmmo(am : int):
	ammo = am
	GUI.ammoCount.text = str(ammo) + "/" + str(currentWeapon["ammo"]) + " rnds"
	if is_network_master():
		rset("ammo", ammo)
	
	
# Add back killer when work is started on the feed
remotesync func death(deathStripResourcePath : String, bullDirection : Vector2, killer : String = "Killer") -> void:
#	emit_signal("killed", killer, G.getCurrentPlayerName())
	visible = false
	# Texture 
	deadBody.texture = load(deathStripResourcePath)
	deadBody.hframes = getFrames(deathStripResourcePath)
	deadBody.frame = G.rng.randi() % deadBody.hframes  
	deadBody.rotation = bullDirection.angle()
	
	# Gameplay
	dead = true
	deadBody.global_position = global_position

	# deadBody is child of world
	get_parent().add_child(deadBody)
	respawnTimer.start()
	
#	reparent(cam, killer)
# get player who killed you
# either have a camera on guy or spawn/reparent in camera

func reparent(node, destination):
	node.get_parent().remove_child(node)
	destination.add_child(node)

func _on_PickUpArea_body_entered(body):
	if body.is_in_group(G.ITEM):
		body.nearPlayer = true
		body.player = self
		itemsNear.append(body)

func _on_PickUpArea_body_exited(body):
	if body.is_in_group(G.ITEM):
		body.nearPlayer = false
		body.player = null
		itemsNear.erase(body)

func _on_HitBox_area_entered(area : Area2D):
	if area.is_in_group(G.BULLET) and self != area.sender and area.penetration > 0:
		health -= area.dmg

		if is_network_master():
			setHealth(health)
		if health <= 0:
			print(area.sender)
			rpc("death", area.deathStrip.resource_path, area.vel) #area.sender maybe add .name , G.getPlayerName(area.sender)


func _on_Respawn_timeout():
	if is_network_master():
		setHealth(MAX_HEALTH)
	respawn()
