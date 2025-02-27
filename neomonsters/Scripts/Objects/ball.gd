extends Node2D

signal ball_spawned  # Signal when ball spawns
signal ball_moved(new_position)  # Signal when ball moves
signal ball_disappeared  # Signal when ball is removed

var last_position = Vector2()  # Track last known position
var rb  # Reference to the RigidBody2D child

func _ready():
	add_to_group("ball")  # Ensures Ball is in the group
	rb = get_node_or_null("RigidBody2D")  # Find the RigidBody2D child

	if rb:
		last_position = rb.global_position
	else:
		print("⚠ Warning: No RigidBody2D found in Ball node!")

	emit_signal("ball_spawned")

func _physics_process(delta):
	if rb:
		# Check if the ball actually moved
		if rb.global_position != last_position:
			emit_signal("ball_moved", rb.global_position)
			last_position = rb.global_position  # Update last position

func _exit_tree():
	emit_signal("ball_disappeared")
