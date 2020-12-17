tool
extends Position3D

export var show_zone_in_editor = true setget _set_show_zone_in_editor
export var spawn_zone_radius = 2 setget _set_spawn_zone_radius
export var dead_zone_radius = 0 setget _set_dead_zone_radius
export var height = 1 setget _set_height

onready var spawn_zone = $SpawnZone
onready var dead_zone = $DeadZone

var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	if Engine.is_editor_hint():
		spawn_zone.visible = show_zone_in_editor
		dead_zone.visible = show_zone_in_editor
	else:
		spawn_zone.hide()
		dead_zone.hide()
		
func get_spawn_point() -> Vector3:
	var angle = rand.randf_range(0,2.0 * PI)
	var radius = rand.randf_range(dead_zone_radius,spawn_zone_radius)
	var height_offset = rand.randf_range(0,height)
	
	var spawn_point = Vector3(radius,height_offset,0)
	spawn_point = spawn_point.rotated(Vector3.UP,angle)
	return spawn_point + transform.origin

func _set_show_zone_in_editor(value):
	show_zone_in_editor = value
	
	if not spawn_zone:
		yield(self,"ready")
	
	spawn_zone.visible = show_zone_in_editor
	dead_zone.visible = show_zone_in_editor

func _set_spawn_zone_radius(value):
	spawn_zone_radius = dead_zone_radius
	if value > dead_zone_radius:
		spawn_zone_radius = value
	
	if not spawn_zone:
		yield(self,"ready")
		
	spawn_zone.mesh.top_radius = spawn_zone_radius
	spawn_zone.mesh.bottom_radius = spawn_zone_radius

func _set_dead_zone_radius(value):
	dead_zone_radius = spawn_zone_radius
	if value < spawn_zone_radius:
		dead_zone_radius = value
	
	if not dead_zone:
		yield(self,"ready")
		
	dead_zone.mesh.top_radius = dead_zone_radius
	dead_zone.mesh.bottom_radius = dead_zone_radius
		
func _set_height(value):
	height = value
	
	if not spawn_zone:
		yield(self,"ready")
		
	spawn_zone.mesh.height = height
	dead_zone.mesh.height = height
