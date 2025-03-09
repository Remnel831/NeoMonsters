extends Node2D

func _ready():
	var lightswitch = $LightSwitch
	lightswitch.connect("button_pressed_lightswitch", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	if $Lights.enabled == true:
		$Lights.enabled = false
	else:
		$Lights.enabled = true


func _on_minigame_btn_pressed():
	get_tree().change_scene_to_file("res://Scenes/Minigames/minigame_1.tscn")
