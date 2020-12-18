extends Node

signal paused_changed(paused)

func _ready():
	vr.leftController.connect("button_pressed",self,"_on_LeftHand_button_pressed")

func _on_LeftHand_button_pressed(button):
	if button == vr.CONTROLLER_BUTTON.ENTER:
	
		# toggle game pause
		if get_tree().paused:
			get_tree().paused = false
		else:
			get_tree().paused = true
		
		emit_signal("paused_changed",get_tree().paused)
