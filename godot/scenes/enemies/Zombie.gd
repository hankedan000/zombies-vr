extends KinematicBody
class_name Zombie

signal on_dead()

# a factor used to smooth the zombies turning speed
#  0 -> never turn
#  1.0 -> instantaneous turning
const LOOK_AT_SMOOTH_FACTOR = 0.05

# the minimum distance (meters) from the player before
# the zombie begins to chew
const CHEW_DISTANCE = 0.5

# zombies max health
export var max_health = 1
# bombies max walking speed
export var speed = 0.5# meters/second
# duration between chews
export var chew_interval = 1
# damage incurred on player by a zombie's chew on
export var chew_damage = 1
# audio stream that gets played when zombie spawns
export var spawn_sound_stream : AudioStream = null
# audio stream that gets played when zombie chews on player
export var chewing_sound_stream : AudioStream = null

onready var spawn_sound = $SpawnSound
onready var chewing_sound = $ChewingSound
onready var chew_timer = $ChewTimer

# the spatial node that the zombie will walk towards
# this is set to the first player at ready-time
var _target : Spatial = null
# the target position the zombie is currently looking at.
# this position will be interpolated to give the zombies
# a smoothed turning motion
var _look_at_pos = null
# a reference to the zombies health bar node
var _health_bar : FloatingHealthBar = null
# the zombies computed walking path
var _path = []
# which path index in above path we are currently at
var _path_node = 0
# the zombies current health amount
var curr_health = 0

func _ready():
	# find health bar in children
	for child in get_children():
		if child is FloatingHealthBar:
			_health_bar = child
			_health_bar.ui_control.set_max_health(max_health)
			break
	
	spawn_sound.stream = spawn_sound_stream
	spawn_sound.play()
	chewing_sound.stream = chewing_sound_stream
	chew_timer.wait_time = chew_interval
	
	curr_health = max_health
	_update_health()

func _physics_process(dt):
	# handle chewing logic
	if _target:
		var target_dist = _target.global_transform.origin - global_transform.origin
		if target_dist.length() > CHEW_DISTANCE:
			stop_chewing()
		elif not chewing() and target_dist.length() <= CHEW_DISTANCE:
			start_chewing()
	elif chewing():
		# no target, don't chew
		stop_chewing()
	
	if _path_node < _path.size():
		# compute zombies direction toward next node in path
		var path_target = _path[_path_node]
		var direction = path_target - global_transform.origin
		if direction.length() < 1 and _path_node < (_path.size() - 1):
			_path_node += 1
			
		if direction.length() > CHEW_DISTANCE:
			move_and_slide(
				direction.normalized() * speed,
				Vector3.UP)
				
			# FIXME this is hack to make the zombies stay on the
			# ground. This should be fixed more properly by adjusting
			# the offset based on the NavigationMeshinstances's
			# 'height' property
			global_transform.origin.y = 0.0
			path_target.y = 0.0
			
			if _look_at_pos:
				# smooth the looking
				_look_at_pos = lerp(
					_look_at_pos,
					path_target,
					LOOK_AT_SMOOTH_FACTOR)
			else:
				_look_at_pos = path_target
			
			look_at(_look_at_pos,Vector3.UP)
			
func chewing():
	return chewing_sound.playing
	
func start_chewing():
	chew()
	chewing_sound.play()
	chew_timer.start()
	
func stop_chewing():
	chewing_sound.playing = false
	chew_timer.stop()

func move_to(target_pos):
	_path_node = 0
	if TheWorld.nav:
		_path = TheWorld.nav.get_simple_path(
			global_transform.origin,
			target_pos)
	else:
		_path = []
		
# call this to have the Zombie recompute it's trajectory
func think():
	# init target to first player in list
	if not _target:
		for player in TheWorld.players:
			# TODO check for closest player, when multiplayer is supported
			_target = player
			break
	
	if _target:
		# move zombie toward target's position
		var target_pos = _target.global_transform.origin
		move_to(target_pos)

func _update_health():
	if _health_bar:
		_health_bar.ui_control.update_health(curr_health)

func die():
	emit_signal("on_dead")
	queue_free()
	
func chew():
	if _target and _target.has_method("hurt"):
		_target.hurt(chew_damage)

func _on_Hitbox_hit(damage):
	curr_health -= damage
	_update_health()
	
	if curr_health <= 0:
		die()

func _on_ThinkTimer_timeout():
	think()

func _on_Zombie_tree_entered():
	think()

func _on_ChewTimer_timeout():
	if chewing():
		chew()
