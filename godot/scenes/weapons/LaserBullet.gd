extends Area

const SPEED = 10# meters/second

export var ttl = 2
export var damage = 1

var lifetime = 0

func _physics_process(dt):
	lifetime += dt
	
	translate(Vector3(0,0,-1) * SPEED * dt)
	
	if lifetime > ttl:
		queue_free()

func _on_collision(node):
	if node.has_method("hit"):
		node.hit(damage)
		
	queue_free()

func _on_LaserBullet_body_entered(body):
	_on_collision(body)

func _on_LaserBullet_area_entered(area):
	_on_collision(area)
