extends OQClass_GrabbableRigidBody

export var bullet_scene : PackedScene = null
export var magazine_size = 12

var ammo = 0

var _bound_controller : ARVRController = null
var _reloading = false

func _ready():
	ammo = magazine_size
	_update_ammo_labels()

func initiate_reload():
	if _reloading:
		# ignore if we're already reloading
		return
	
	$ReloadTimer.start()
	_reloading = true

func _update_ammo_labels():
	var ammo_str = str(ammo)
	$AmmoLabelLeft.set_label_text(ammo_str)
	$AmmoLabelRight.set_label_text(ammo_str)

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
	if ammo <= 0:
		# wait for reload to finish
		$EmptyGunSound.play()
		return
	
	$ShootSound.play(0.16)
	ammo -= 1
	_update_ammo_labels()
	
	if bullet_scene:
		var new_bullet : Spatial = bullet_scene.instance()
		new_bullet.global_transform = $BulletSpawn.global_transform
		get_tree().current_scene.add_child(new_bullet)
		
	if ammo <= 0:
		# auto initiate reload
		initiate_reload()

func _controller_button_pressed(index):
	if index == vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		_shoot()

func _on_ReloadTimer_timeout():
	_reloading = false
	ammo = magazine_size
	_update_ammo_labels()
