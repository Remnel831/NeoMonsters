extends Node2D

var ball_instance: Node2D = null  # Stores the ball instance to delete later

func _on_toy_barrel_ridged_body_create_ball():
	if ball_instance and is_instance_valid(ball_instance):
		_delete_ball()
	else:
		_spawn_ball()

func _spawn_ball():
	var ball_scene = load("res://Scenes/Objects/ball.tscn")  # Ensure correct scene path
	if ball_scene:
		ball_instance = ball_scene.instantiate()
		get_parent().add_child(ball_instance)
		
		# Set initial position based on child RigidBody2D's CollisionShape2D center
		var center_position = _get_collision_shape_center()
		ball_instance.global_position = center_position
		ball_instance.set_deferred("global_position", center_position)

func _process(_delta):
	if ball_instance and is_instance_valid(ball_instance):
		ball_instance.global_position = _get_collision_shape_center()

func _delete_ball():
	if ball_instance:
		ball_instance.queue_free()
		ball_instance = null

func _get_collision_shape_center() -> Vector2:
	for child in get_children():
		if child is RigidBody2D:
			for grandchild in child.get_children():
				if grandchild is CollisionShape2D:
					return child.global_position + grandchild.shape.get_rect().get_center()
	return global_position
