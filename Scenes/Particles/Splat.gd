extends Particles2D


var life


# Called when the node enters the scene tree for the first time.
func _ready():
	life = lifetime / speed_scale
	emitting = true
	$Dust.emitting = true

func _physics_process(delta):
	if life < lifetime and get_node_or_null("Aoe"):
		$Aoe.queue_free()
	life -= delta
	if life < 0:
		queue_free()


func _on_Aoe_body_entered(body):
	if body.is_in_group(Global.Damageable):
		var impulse: Vector2 = body.position - position
		body.apply_impulse(Vector2(0, 0), impulse.normalized() * 16384 / max(1, impulse.length()))
#		body.damage(10)
