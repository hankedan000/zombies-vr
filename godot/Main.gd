extends Spatial

onready var l_controller = $ARVROrigin/LeftHand
onready var r_controller = $ARVROrigin/RightHand
onready var l_hand_label = $ARVROrigin/LeftHand/LeftHandLabel
onready var keyboard = $Keyboard
onready var hud = $ARVROrigin/HUD
onready var origin = $ARVROrigin

# units per second
const SLOW_WALK_SPEED = 1.0

# rotations per second
const ROTATE_SPEED = 2 * PI / 4.0

func _ready():
	vr.initialize()
		
	l_hand_label.set_label_text("We're Ready!")
	
func _physics_process(dt):
	# forward/back walk strength (forward is positive)
	# range: -1 to +1
	var walk_fb = Vector3(0,0,-1*l_controller.get_joystick_axis(1))
	# left/right walk strength (right is positive)
	# range: -1 to +1
	var walk_lr = Vector3(l_controller.get_joystick_axis(0),0,0)
	
	# translate player based on walking vector
	var walk_dist = SLOW_WALK_SPEED * (walk_fb + walk_lr) * dt
	origin.translate(walk_dist)
	
	var rotate_angle = ROTATE_SPEED * r_controller.get_joystick_axis(0) * dt
	origin.rotate(Vector3(0,-1,0),rotate_angle)
	
func _on_Keyboard_text_input_cancel():
	keyboard.hide()

func _on_MenuPanel_keyboard_request():
	keyboard.show()

func _on_LeftHand_button_pressed(button):
	if button == vr.CONTROLLER_BUTTON.ENTER:
		# menu button on left controller
		# recenter HUD where player is looking
		hud.global_transform = $ARVROrigin/ARVRCamera/HUD_Spawn.global_transform
	
		# toggle visibility
		if hud.visible:
			hud.hide()
		else:
			hud.show()
