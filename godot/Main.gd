extends Spatial

var BasicZombies = preload("res://scenes/enemies/BasicZombie.tscn")

onready var zombie_spawn_zone = $Scenery/SpawnZone
onready var zombie_spawn_timer = $Timers/ZombieSpawnTimer
onready var zombies = $Navigation/Zombies

func _ready():
	vr.initialize()
	
	TheWorld.nav = $Navigation
	
func _on_ZombieSpawnTimer_timeout():
	var spawn_point = zombie_spawn_zone.get_spawn_point()
	spawn_point.y = 0.0# always put zombies on the ground
	
	var new_zombie = BasicZombies.instance()
	new_zombie.global_translate(spawn_point)
	zombies.add_child(new_zombie)
	
	var MIN_WAIT_TIME = 2.0
	var wait_time = max(MIN_WAIT_TIME,zombie_spawn_timer.wait_time * 0.9)
	zombie_spawn_timer.start(wait_time)
