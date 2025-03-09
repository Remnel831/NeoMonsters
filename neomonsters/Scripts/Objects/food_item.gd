extends Node

@export var FoodValue = 0
@warning_ignore("UNUSED_SIGNAL")
signal feeding_signal
var rb

func _ready():
	add_to_group("Food")
	rb = get_node_or_null("RigidBody2D") 
	rb.contact_monitor = true
	rb.connect("body_entered", Callable(self, "feed_to_monster"))
		
func feed_to_monster():
	print("monster collided")
	emit_signal('feeding_signal', FoodValue)
	queue_free()
	
