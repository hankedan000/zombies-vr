extends Control

var l_controller : ARVRController = null
var r_controller : ARVRController = null

onready var left_joyx = $LeftJoystick/X
onready var left_joyy = $LeftJoystick/Y
onready var right_joyx = $RightJoystick/X
onready var right_joyy = $RightJoystick/Y

func _ready():
	l_controller = vr.leftController
	r_controller = vr.rightController
	
func _process(delta):
	if l_controller:
		left_joyx.text = "Left_X: %f" % l_controller.get_joystick_axis(0)
		left_joyy.text = "Left_Y: %f" % l_controller.get_joystick_axis(1)
	
	if r_controller:
		right_joyx.text = "Right_X: %f" % r_controller.get_joystick_axis(0)
		right_joyy.text = "Right_Y: %f" % r_controller.get_joystick_axis(1)
