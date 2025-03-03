extends Node2D

func _ready():
	var lightswitch = $LightSwitch
	lightswitch.connect("button_pressed_lightswitch", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	if $Lights.enabled == true:
		$Lights.enabled = false
	else:
		$Lights.enabled = true
