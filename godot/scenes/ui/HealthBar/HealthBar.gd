extends Spatial
class_name HealthBar

func update_health(curr_health,max_health):
	$Canvas.ui_control.min_value = 0
	$Canvas.ui_control.value = curr_health
	$Canvas.ui_control.max_value = max_health
