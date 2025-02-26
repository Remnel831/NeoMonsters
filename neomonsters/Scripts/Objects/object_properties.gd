extends RigidBody2D

var dragging = false
var spring_joint: DampedSpringJoint2D
var max_velocity = 4500.0  # Maximum speed limit
var has_polygon_collision = false

# Global flag to prevent multiple objects from being grabbed at the same time
static var global_dragging = false

func _ready():
	# Check if the object has a CollisionPolygon2D
	for child in get_children():
		if child is CollisionPolygon2D:
			has_polygon_collision = true
			break

func _process(delta):
	if dragging and spring_joint:
		var target_position = get_global_mouse_position()
		var direction = target_position - global_position
		var new_velocity = direction * 20  # Adjust speed multiplier if needed

		# Cap the velocity at max_velocity
		if new_velocity.length() > max_velocity:
			new_velocity = new_velocity.normalized() * max_velocity

		linear_velocity = new_velocity  # Apply capped velocity

	# Always check if the left mouse button is released
	if dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_detach_joint()
		dragging = false
		global_dragging = false  # Release the global drag lock

	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_mouse_over() and not dragging and not global_dragging:
			dragging = true
			global_dragging = true  # Set the global drag lock
			_attach_joint()

func _is_mouse_over() -> bool:
	var space_state = get_world_2d().direct_space_state
	
	if has_polygon_collision:
		# Use intersect_shape() for CollisionPolygon2D
		var shape_query = PhysicsShapeQueryParameters2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 5  # Small radius to simulate point detection

		shape_query.set_shape(circle_shape)
		shape_query.transform = Transform2D(0, get_global_mouse_position())
		shape_query.collision_mask = collision_layer

		var result = space_state.intersect_shape(shape_query)
		for hit in result:
			if hit.collider == self:
				return true
	else:
		# Use intersect_point() for CollisionShape2D
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collision_mask = collision_layer

		var result = space_state.intersect_point(query)
		for hit in result:
			if hit.collider == self:
				return true

	return false

func _attach_joint():
	if spring_joint == null:
		# Create a DampedSpringJoint2D **directly on the object itself**
		spring_joint = DampedSpringJoint2D.new()
		get_parent().add_child(spring_joint)

		# Connect the object (`node_a`) to the mouse position (`node_b`)
		spring_joint.node_a = get_path()
		spring_joint.node_b = get_path()

		# Spring properties of dragged object
		spring_joint.length = 0.0  # Object should stay directly at the mouse
		spring_joint.stiffness = 100.0  # High stiffness for instant response
		spring_joint.damping = 20.0  # Prevents wobbly movement

func _detach_joint():
	if spring_joint:
		spring_joint.queue_free()
		spring_joint = null
