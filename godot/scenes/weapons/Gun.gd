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
	
func _update_ammo_label_visibility():
	var ll_v = Quat($AmmoLabelLeft.global_transform.basis) * Vector3.FORWARD
	var rl_v = Quat($AmmoLabelRight.global_transform.basis) * Vector3.FORWARD
	var camera_v = Quat(vr.vrCamera.global_transform.basis) * Vector3.FORWARD
	
	# dot product tells us cosine of angle between label normal and camera
	# normal. this allows us to make the ammo labels less transparent when
	# the player is looking at the gun.
	var ll_visibility = ll_v.dot(camera_v)
	var rl_visibility = rl_v.dot(camera_v)
	
	var ll_font = $AmmoLabelLeft.font_color
	ll_font.a = Utils.map(ll_visibility,0.25,0.75,0.0,1.0)
	$AmmoLabelLeft.ui_label.add_color_override("font_color", ll_font)
	var rl_font = $AmmoLabelRight.font_color
	rl_font.a = Utils.map(rl_visibility,0.25,0.75,0.0,1.0)
	$AmmoLabelRight.ui_label.add_color_override("font_color", rl_font)

func _physics_process(delta):
	_update_ammo_label_visibility()
	
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
	if TheWorld.paused():
		# don't shoot while game is paused
		return
	
	if index == vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		_shoot()

func _on_ReloadTimer_timeout():
	_reloading = false
	ammo = magazine_size
	_update_ammo_labels()
