extends Node2D

@onready var platforms = $Platforms  # Reference to the Platforms node
@export var coin_scene: PackedScene  # Assign the Coin scene in the Inspector

var total_coins = 0
var max_coins = 10
var coins = []

func _ready():
	spawn_coins()

func spawn_coins():
	var platform_list = platforms.get_children()
	platform_list.shuffle()  # Shuffle platforms to randomize placement
	
	total_coins = min(platform_list.size(), max_coins)  # Ensure max 10 coins
	coins.clear()
	
	for i in range(total_coins):
		var platform = platform_list[i]
		var static_body = platform.find_child("StaticBody2D", true, false)
		if not static_body:
			continue  # Skip if no StaticBody2D found
		
		var collision_shape = static_body.find_child("CollisionShape2D", true, false)
		var platform_height = 20  # Default height if no CollisionShape2D is found
		
		if collision_shape and collision_shape.shape is RectangleShape2D:
			platform_height = collision_shape.shape.extents.y * 2
		
		var coin_instance = coin_scene.instantiate()
		
		# Position the coin above the platform, ensuring enough space
		coin_instance.global_position = static_body.global_position + Vector2(0, -platform_height - 160)
		
		add_child(coin_instance)
		coins.append(coin_instance)
		
		# Connect signal to track when a coin is collected
		coin_instance.area.connect("tree_exited", Callable(self, "_on_coin_removed").bind(coin_instance))

func _on_coin_removed(coin_instance):
	coins.erase(coin_instance)
	if coins.is_empty():
		reset_game()

func reset_game():
	await get_tree().create_timer(5).timeout  # Small delay before resetting
	get_tree().reload_current_scene()  # Reload scene to reset everything
