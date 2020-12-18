extends ProgressBar
class_name HealthBar

func set_max_health(max_health):
	max_value = max_health

func set_health(health_value):
	value = health_value

func update_health(new_health):
	$Tween.interpolate_property(
		self,"value",
		value,new_health,
		0.1,
		Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Tween.start()
