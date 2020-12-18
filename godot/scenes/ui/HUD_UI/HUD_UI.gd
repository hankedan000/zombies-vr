extends Control
class_name HUD_UI

var health_bar : HealthBar = null

func _ready():
	health_bar = $HealthBar
