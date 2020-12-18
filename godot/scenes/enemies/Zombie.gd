extends KinematicBody
class_name Zombie

signal on_dead()

# zombies max health
export var max_health = 1
# bombies max walking speed
export var speed = 0.5# meters/second
# audio stream that gets played when zombie spawns
export var spawn_sound_stream : AudioStream = null

onready var spawn_sound = $SpawnSound

# the spatial node that the zombie will walk towards
# this is set to the first player at ready-time
var target : Spatial = null
# a reference to the zombies health bar node
var _health_bar : HealthBar = null
# the zombies computed walking path
var _path = []
# which path index in above path we are currently at
var _path_node = 0
# the zombies current health amount
var curr_health = 0

func _ready():
	# find health bar in children
	for child in get_children():
		if child is HealthBar:
			_health_bar = child
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
	
	if _path_node < _path.size():
		# compute zombies direction toward next node in path
		var direction = _path[_path_node] - global_transform.origin
		if direction.length() < 1:
			_path_node += 1
		else:
			move_and_slide(
				direction.normalized() * speed,
				Vector3.UP)
				
			# FIXME this is hack to make the zombies stay on the
			# ground. This should be fixed more properly by adjusting
			# the offset based on the NavigationMeshinstances's
			# 'height' property
			global_transform.origin.y = 0.0

func move_to(target_pos):
	_path_node = 0
	if TheWorld.nav:
		_path = TheWorld.nav.get_simple_path(
			global_transform.origin,
			target_pos)
	else:
		_path = []

func _update_health():
	if _health_bar:
		_health_bar.update_health(curr_health,max_health)

func die():
	emit_signal("on_dead")
	queue_free()

func _on_Hitbox_hit(damage):
	curr_health -= damage
	_update_health()
	
	if curr_health <= 0:
		die()

func _on_MoveTimer_timeout():
	if target:
		# move zombie toward target's position
		var target_pos = target.global_transform.origin
		move_to(target_pos)
