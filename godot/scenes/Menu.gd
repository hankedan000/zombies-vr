extends MarginContainer

signal keyboard_request()

const MSAA_VALUES = ["Disabled","2x","4x","8x","16x","AndroidVR 2x","AndroidVR 4x"]

onready var msaa_value_le = $Panel/Margin/VBox/Buttons/MSAA/MSAA_Value
onready var msaa_slider = $Panel/Margin/VBox/Buttons/MSAA/MSAA_Slider

func _ready():
	msaa_slider.value = int(ProjectSettings.get("rendering/quality/filters/msaa"))
	_update_msaa_value()

func _on_Keyboard_pressed():
	emit_signal("keyboard_request")

func _get_msaa_idx():
	return int(msaa_slider.value)

func _update_msaa_value():
	var idx = _get_msaa_idx()
	get_viewport().set_msaa(idx)
	msaa_value_le.text = MSAA_VALUES[idx]

func _on_MSAA_Slider_value_changed(value):
	_update_msaa_value()
