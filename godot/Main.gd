extends Spatial

var BasicZombies = preload("res://scenes/enemies/BasicZombie.tscn")

onready var l_controller = $OQ_ARVROrigin/LeftHand
onready var r_controller = $OQ_ARVROrigin/RightHand
onready var keyboard = $Keyboard
onready var hud = $OQ_ARVROrigin/HUD
onready var menu = $OQ_ARVROrigin/HUD/Menu
onready var zombie_spawn_zone = $Scenery/SpawnZone
onready var zombie_spawn_timer = $Timers/ZombieSpawnTimer
onready var zombies = $Zombies

# units per second
const SLOW_WALK_SPEED = 1.0

# rotations per second
const ROTATE_SPEED = 2 * PI / 4.0

func _ready():
	vr.initialize()
	
	# add player
	TheWorld.add_player($OQ_ARVROrigin)
	
func _physics_process(dt):
	# forward/back walk strength (forward is positive)
	# range: -1 to +1
	var walk_fb = Vector3(0,0,-1*l_controller.get_joystick_axis(1))
	# left/right walk strength (right is positive)
	# range: -1 to +1
	var walk_lr = Vector3(l_controller.get_joystick_axis(0),0,0)
	
	# translate player based on walking vector
	var walk_dist = SLOW_WALK_SPEED * (walk_fb + walk_lr) * dt
	var camera_quat = Quat(vr.vrCamera.transform.basis)
	walk_dist = camera_quat.xform(walk_dist)
	# TODO: figure out how to project walk vector into horizontal plane.
	# this approach of zeroing out the y-component removes velocity
	# magnitude, so the player will walk slower when looking up or down.
	walk_dist.y = 0
	vr.vrOrigin.translate(walk_dist)
	
	var rotate_angle = ROTATE_SPEED * -r_controller.get_joystick_axis(0) * dt
	vr.vrOrigin.rotate(Vector3.UP,rotate_angle)
	
func _on_Keyboard_text_input_cancel():
	keyboard.hide()

func _on_MenuPanel_keyboard_request():
	keyboard.show()

func _on_ZombieSpawnTimer_timeout():
	var spawn_point = zombie_spawn_zone.get_spawn_point()
	spawn_point.y = 0.0# always put zombies on the ground
	
	var new_zombie = BasicZombies.instance()
	new_zombie.global_translate(spawn_point)
	zombies.add_child(new_zombie)
	
	var MIN_WAIT_TIME = 2.0
	var wait_time = max(MIN_WAIT_TIME,zombie_spawn_timer.wait_time * 0.9)
	zombie_spawn_timer.start(wait_time)

func _on_GameStateController_paused_changed(paused):
	# recenter HUD where player is looking
	hud.global_transform = $OQ_ARVROrigin/OQ_ARVRCamera/HUD_Spawn.global_transform
	
	if paused:
		menu.show()
	else:
		menu.hide()
