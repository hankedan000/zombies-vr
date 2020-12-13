extends Area

const SPEED = 10# meters/second

export var ttl = 2

var lifetime = 0

func _physics_process(dt):
	lifetime += dt
	
	translate(Vector3(0,0,-1) * SPEED * dt)
	
	if lifetime > ttl:
		queue_free()
