extends RigidBody2D
@warning_ignore("UNUSED_SIGNAL")#These signals connect to toy_barrel.gd
signal create_ball
@warning_ignore("UNUSED_SIGNAL")
signal ball_spawn
 

var dragging = false
var spring_joint: DampedSpringJoint2D
var max_velocity = 4500.0  # Maximum speed limit
var has_polygon_collision = false
var click_offset = Vector2.ZERO  # Offset where player clicked
var last_click_time = 0

# Global flag to prevent multiple objects from being grabbed at the same time
static var global_dragging = false
static var last_dragged_object = null  # Tracks the last dragged object
static var last_drag_time = 0.0  # Time of the last drag

const DOUBLE_DRAG_TIME = 0.5  # Time in seconds to detect double drag

func _ready():
	# Check if the object has a CollisionPolygon2D
	for child in get_children():
		if child is CollisionPolygon2D:
			has_polygon_collision = true
			break

func _process(delta):
	if dragging and spring_joint:
		var target_position = get_global_mouse_position() - click_offset
		var direction = target_position - global_position
		var new_velocity = direction * 20  # Adjust speed multiplier if needed

		# Cap the velocity at max_velocity
		if new_velocity.length() > max_velocity:
			new_velocity = new_velocity.normalized() * max_velocity

		# Prevent jittering: Reduce velocity if colliding with a static body
		if is_colliding_with_static(new_velocity * delta):
			linear_velocity *= 0.6  # Gradually slow down instead of snapping
		else:
			linear_velocity = new_velocity  # Apply capped velocity

	# Always check if the left mouse button is released
	if dragging and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_detach_joint()
		dragging = false
		global_dragging = false  # Release the global drag lock

	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_mouse_over() and not dragging and not global_dragging:
			# Check if this object was dragged within DOUBLE_DRAG_TIME
			var current_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
			if last_dragged_object == self and (current_time - last_drag_time) <= DOUBLE_DRAG_TIME:
				# If dragged twice in a short time, emit the signal if applicable
				if name == "ToyBarrelRidgedBody":
					emit_signal("create_ball")

			# Update last dragged object and time
			last_dragged_object = self
			last_drag_time = current_time

			dragging = true
			global_dragging = true  # Set the global drag lock
			click_offset = get_global_mouse_position() - global_position  # Store click offset
			_attach_joint()

func is_colliding_with_static(motion: Vector2) -> bool:
	# Test if moving the body would result in a collision
	var collision = move_and_collide(motion)
	if collision and collision.get_collider() is StaticBody2D:
		return true
	return false

func _is_mouse_over() -> bool:
	var space_state = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()

	if has_polygon_collision:
		var shape_query = PhysicsShapeQueryParameters2D.new()
		# Manually assign layers to polygons
		var poly_layers = {}  # Dictionary to store each polygon and its intended layer

		for child in get_children():
			if child is CollisionPolygon2D:
				# Assuming layer assignment is stored in a metadata field
				# Example: child.set_meta("custom_layer", 0b0001)  # Set custom layer in the editor
				var assigned_layer = child.get_meta("custom_layer", collision_layer)  # Default to body's layer
				poly_layers[child] = assigned_layer

		# Iterate through each CollisionPolygon2D and check its custom layer
		for poly in poly_layers.keys():
			var segment_array = []
			var points = poly.polygon
			var custom_layer = poly_layers[poly]

			if points.size() > 1:
				for i in range(points.size() - 1):
					var segment = SegmentShape2D.new()
					segment.a = points[i]
					segment.b = points[i + 1]
					segment_array.append(segment)
				# Close the shape if necessary
				var closing_segment = SegmentShape2D.new()
				closing_segment.a = points[-1]
				closing_segment.b = points[0]
				segment_array.append(closing_segment)

			# Check each segment separately using the custom layer
			for segment in segment_array:
				shape_query.set_shape(segment)
				shape_query.transform = Transform2D.IDENTITY.translated(mouse_pos)
				shape_query.collision_mask = custom_layer  # Override the body's collision layer

				var result = space_state.intersect_shape(shape_query)
				for hit in result:
					if hit.collider == self:
						if get_parent().name == "ToyBarrel":
							_handle_toy_barrel_double_click()
						return true

	else:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collision_mask = collision_layer  # Default to RigidBody2D's collision layer

		var result = space_state.intersect_point(query)
		for hit in result:
			if hit.collider == self:
				if name == "ToyBarrel":
					_handle_toy_barrel_double_click()
				return true

	return false


func _handle_toy_barrel_double_click():
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	if current_time - last_click_time <= DOUBLE_DRAG_TIME:
		# Find ToyBarrel (parent) and emit signal
		if get_parent().has_signal("create_ball"):
			get_parent().emit_signal("create_ball")
	last_click_time = current_time

func _attach_joint():
	if spring_joint == null:
		# Create a DampedSpringJoint2D at the clicked position
		spring_joint = DampedSpringJoint2D.new()
		get_parent().add_child(spring_joint)

		# Position the spring joint at the mouse click position
		spring_joint.global_position = get_global_mouse_position()

		# Connect the object (`node_a`) to the click position (`node_b`)
		spring_joint.node_a = get_path()
		spring_joint.node_b = get_parent().get_path()  # Connect to world instead of object center

		# Spring properties of dragged object
		spring_joint.length = 0.0  # Object should stay directly at the mouse
		spring_joint.stiffness = 100.0  # High stiffness for instant response
		spring_joint.damping = 20.0  # Prevents wobbly movement

func _detach_joint():
	if spring_joint:
		spring_joint.queue_free()
		spring_joint = null
