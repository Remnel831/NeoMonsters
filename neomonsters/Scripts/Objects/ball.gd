extends Node2D
@warning_ignore("UNUSED_SIGNAL")
signal ball_spawned  # Signal when ball spawns
@warning_ignore("UNUSED_SIGNAL")
signal ball_moved(new_position)  # Signal when ball moves
@warning_ignore("UNUSED_SIGNAL")
signal ball_disappeared  # Signal when ball is removed

var rb  # Reference to the RigidBody2D child

func _ready():
	add_to_group("ball")  # Ensures Ball is in the group
	rb = get_node_or_null("RigidBody2D")  # Find the RigidBody2D child

	if not rb:
		print("⚠ Warning: No RigidBody2D found in Ball node!")
	ball_spawned.emit()
	emit_signal("ball_spawned")

func _process(_delta):
	if rb:
		emit_signal("ball_moved", rb.global_position)  # Continuously update position

func _exit_tree():
	emit_signal("ball_disappeared")
