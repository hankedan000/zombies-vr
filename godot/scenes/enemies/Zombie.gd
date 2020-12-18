extends RigidBody

signal on_dead()

export var max_health = 1
export var speed = 0.5# meters/second
export var spawn_sound_stream : AudioStream = null

onready var spawn_sound = $SpawnSound

var target : Spatial = null
var _health_bar : HealthBar = null
var curr_health = 0

func _ready():
	# find health bar in children
	for child in get_children():
		if child is HealthBar:
			_health_bar = child
			print("ITS A HEALTH BAR!")
			break
	
	spawn_sound.stream = spawn_sound_stream
	spawn_sound.play()
	
	curr_health = max_health
	_update_health()

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
	
func _update_health():
	if _health_bar:
		_health_bar.update_health(curr_health,max_health)

func die():
	emit_signal("on_dead")
	queue_free()

func hurt(damage):
	curr_health -= damage
	_update_health()
	
	if curr_health <= 0:
		die()
