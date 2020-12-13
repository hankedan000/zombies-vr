extends OQClass_GrabbableRigidBody

export var bullet_scene : PackedScene = null

var _bound_controller : ARVRController = null

func _physics_process(delta):
	if not is_grabbed:
		if _bound_controller:
			# unbind the controller once gun is dropped
			_bound_controller.disconnect("button_pressed",self,"_controller_button_pressed")
			_bound_controller = null
		
		return
		
	var target_parent = target_node.get_parent()
	# if target's parent is controller, connect to button press signal
	if target_parent is ARVRController:
		_bound_controller = target_parent
		_bound_controller.connect("button_pressed",self,"_controller_button_pressed")
	
	# align gub with grabbed target node
	transform = target_node.transform

func _shoot():
	$ShootSound.play(0.16)
	
	if bullet_scene:
		var new_bullet : Spatial = bullet_scene.instance()
		new_bullet.global_transform = $BulletSpawn.global_transform
		get_tree().current_scene.add_child(new_bullet)

func _controller_button_pressed(index):
	if index == vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		_shoot()
