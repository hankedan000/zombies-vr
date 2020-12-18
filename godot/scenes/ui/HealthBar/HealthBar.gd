extends TextureProgress
class_name HealthBar

var GREEN_BAR = preload("res://assets/ui/barHorizontal_green_mid.png")
var YELLOW_BAR = preload("res://assets/ui/barHorizontal_yellow_mid.png")
var RED_BAR = preload("res://assets/ui/barHorizontal_red_mid.png")

var _health = value
var _max_health = max_value

func set_max_health(max_health):
	_max_health = max_health

func set_health(health_value):
	_health = health_value
	var percent = (_health / _max_health) * 100.0
	value = (percent / 100.0) * max_value
	if percent <= 20:
		set("texture_progress",RED_BAR)
	elif percent <= 50:
		set("texture_progress",YELLOW_BAR)
	else:
		set("texture_progress",GREEN_BAR)

func update_health(new_health):
	$Tween.interpolate_method(
		self,"set_health",
		_health,new_health,
		0.1,
		Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Tween.start()
