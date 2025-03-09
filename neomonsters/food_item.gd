extends Node

var FoodValue = 0
signal feeding_signal

func _ready():
	add_to_group("Food")
	
func feed_to_monster():
	feeding_signal.emit(FoodValue)
	
