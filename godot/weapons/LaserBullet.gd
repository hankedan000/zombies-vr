extends Area

const SPEED = 10# meters/second

export var ttl = 2
export var damage = 2

var lifetime = 0

func _physics_process(dt):
	lifetime += dt
	
	translate(Vector3(0,0,-1) * SPEED * dt)
	
	if lifetime > ttl:
		queue_free()

func _on_LaserBullet_body_entered(body):
	if body.has_method("hurt"):
		body.hurt(damage)
		
	queue_free()
