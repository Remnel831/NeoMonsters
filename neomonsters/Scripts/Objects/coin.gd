extends Node2D

@onready var area = $Area2D  # Reference to the Area2D child

func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(_body):
		Global.point += 1  # Increase global point counter
		queue_free()  # Remove the coin
