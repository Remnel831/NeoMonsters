extends Node2D

signal button_pressed_lightswitch

func _on_switch_pressed():
	button_pressed_lightswitch.emit()
