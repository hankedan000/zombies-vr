extends "res://OQ_Toolkit/OQ_ARVROrigin/scripts/OQ_ARVROrigin.gd"

# units per second
const SLOW_WALK_SPEED = 1.0

# rotations per second
const ROTATE_SPEED = 2 * PI / 4.0

onready var l_controller = $LeftHand
onready var r_controller = $RightHand
onready var left_raycast = $LeftHand/Feature_UIRayCast
onready var right_raycast = $RightHand/Feature_UIRayCast
onready var menu_spawn = $Camera/MenuSpawn
onready var menu_root = $MenuRoot

func _physics_process(dt):
	if TheWorld.paused():
		# don't move while game is paused
		return
	
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

func _on_GameStateController_paused_changed(paused):
	# recenter HUD where player is looking
	menu_root.global_transform = menu_spawn.global_transform
	
	right_raycast.active = paused
	if paused:
		menu_root.show()
	else:
		menu_root.hide()

func _on_Player_tree_entered():
	TheWorld.add_player(self)
