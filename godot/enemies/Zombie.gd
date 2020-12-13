extends RigidBody

signal on_dead()

export var health = 1
export var speed = 0.5# meters/second
export var spawn_sound_stream : AudioStream = null

onready var spawn_sound = $SpawnSound

var target : Spatial = null

func _ready():
	spawn_sound.stream = spawn_sound_stream
	spawn_sound.play()

func _physics_process(dt):
	# init target to first player in list
	if not target:
		for player in TheWorld.players:
			# TODO check for closest player, when multiplayer is supported
			target = player
			break
	
	# still no target set... quit early
	if not target:
		return
		
	transform = transform.looking_at(target.transform.origin,Vector3.UP)
	translate(Vector3(0,0,-1) * speed * dt)

func die():
	emit_signal("on_dead")
	queue_free()

func hurt(damage):
	health -= damage
	if health <= 0:
		die()
