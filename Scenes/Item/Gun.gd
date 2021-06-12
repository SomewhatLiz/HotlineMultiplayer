extends Sprite

onready var muzzle = get_node_or_null("Muzzle")
export var dmg = 8
export var ammo = 6
export var sound = 0
export var fireRate = 0.5
export var spread = 3
export var pelletCount = 1
export var aniLength = 1
export var itemPath = preload("res://Art/Items/image_part_003.png")
export var weaponName = "magnum"
export var deathStrip = preload("res://Art/Player/sprPBackShotgun_strip4.png")
