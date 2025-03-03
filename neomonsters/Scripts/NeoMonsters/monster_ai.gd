extends CharacterBody2D
@onready var _animated_sprite = $AnimatedSprite2D

const GRAVITY = 980
const SPEED = 300
const FORCE_ON_COLLISION = 200  # General push force
const BALL_HIT_FORCE_Y = -6000 # Upward force applied to ball
const BALL_HIT_FORCE_X_MULTIPLIER = 30.0  # How much AI speed affects ball push
const JUMP_FORCE_MIN = -300
const JUMP_FORCE_MAX = -600
const MIN_X = 40
const MAX_X = 1560
const STATUS_CHECK_INTERVAL = 5.0  # Check for ball every 5 sec
const BALL_FOLLOW_THRESHOLD = 40  # Increase for bigger delay in following
const BALL_JUMP_MIN_HEIGHT = 115  # Min height for AI to jump toward the ball
const BALL_JUMP_MAX_HEIGHT = 225  # Increase max height to encourage more jumps
const BALL_JUMP_MAX_LENGTH = 40  # How far horizontally the ball can be to allow jumps
const IDLE_WAIT_MIN = 1.0  # Min time to wait at a wander point
const IDLE_WAIT_MAX = 3.0  # Max time to wait at a wander point
const IDLE_JUMP_MIN = 2.0  # Min idle jump interval
const IDLE_JUMP_MAX = 10.0  # Max idle jump interval

enum Status { IDLE, PLAYFUL }
var current_status = Status.IDLE

var ball_node = null  # Parent Node2D (holds signals)
var ball_rb = null  # Child RigidBody2D (physics)
var ball_detected = false
var ball_position = null
var direction = 1  # Track movement direction

var wander_target_x = 0  # AI's target position in idle mode
var idle_wait_timer = null  # Timer for waiting at a target
var idle_jump_timer = null  # Timer for random jumps

func _ready():
	position.x = clamp(position.x, MIN_X, MAX_X)
	#adding idle animation here
	_animated_sprite.play("IdleAnimation")

	# Timers for wandering and jumping in idle mode
	idle_wait_timer = Timer.new()
	idle_wait_timer.one_shot = true
	idle_wait_timer.timeout.connect(_on_idle_wait_timer_timeout)
	add_child(idle_wait_timer)

	idle_jump_timer = Timer.new()
	idle_jump_timer.one_shot = true
	idle_jump_timer.timeout.connect(_on_idle_jump_timer_timeout)
	add_child(idle_jump_timer)
	
	pick_new_wander_target()  # Set initial idle movement
	start_idle_jump_timer()  # Start random jumping
	check_ball_status()
	status_check_loop()

func _physics_process(delta):
	self.velocity.y += GRAVITY * delta

	if current_status == Status.PLAYFUL and ball_position:
		follow_ball_x()
		check_jump_condition()
	elif current_status == Status.IDLE:
		wander()

	move_and_slide()
	apply_force_to_collided_object()

func wander():
	if abs(position.x - wander_target_x) < 5:  # Reached target, wait
		self.velocity.x = 0
		if not idle_wait_timer.is_stopped():
			return  # Already waiting
		idle_wait_timer.start(randf_range(IDLE_WAIT_MIN, IDLE_WAIT_MAX))  # Pick a new wait time
	else:
		direction = sign(wander_target_x - position.x)
		self.velocity.x = SPEED * direction  # Move toward target

func pick_new_wander_target():
	wander_target_x = randi_range(MIN_X, MAX_X - 40)  # Random position within limits

func start_idle_jump_timer():
	idle_jump_timer.start(randf_range(IDLE_JUMP_MIN, IDLE_JUMP_MAX))  # Pick a random jump interval

func _on_idle_jump_timer_timeout():
	if current_status == Status.IDLE and is_on_floor():
		jump()
	start_idle_jump_timer()  # Restart timer after jumping

func _on_idle_wait_timer_timeout():
	pick_new_wander_target()  # Pick a new destination after waiting

func follow_ball_x():
	if not ball_position:
		return

	var ball_x = ball_position.x
	var distance_to_ball = abs(ball_x - position.x)

	if distance_to_ball > BALL_FOLLOW_THRESHOLD:
		direction = sign(ball_x - position.x)
		self.velocity.x = SPEED * direction
		
func check_jump_condition():
	if ball_position:
		var viewport_height = get_viewport_rect().size.y
		var adjusted_ball_y = (viewport_height - ball_position.y) - 107  # Convert ball Y to AI's system and adjust for ground level
		var ball_x_diff = abs(ball_position.x - position.x)
		# Check if ball is within jump range
		if BALL_JUMP_MIN_HEIGHT <= adjusted_ball_y and adjusted_ball_y <= BALL_JUMP_MAX_HEIGHT and ball_x_diff <= BALL_JUMP_MAX_LENGTH:
			jump()

func jump():
	if is_on_floor():
		self.velocity.y = randi_range(JUMP_FORCE_MIN, JUMP_FORCE_MAX)

func status_check_loop():
	while true:
		await get_tree().create_timer(STATUS_CHECK_INTERVAL).timeout
		check_ball_status()

func check_ball_status():
	var found_ball = get_tree().get_nodes_in_group("ball").front() if get_tree().get_nodes_in_group("ball") else null

	if found_ball and not ball_detected:
		ball_node = found_ball  
		ball_rb = found_ball if found_ball is RigidBody2D else found_ball.get_node_or_null("RigidBody2D")

		if not ball_rb:
			return

		ball_position = ball_rb.global_position  

		ball_node.ball_spawned.connect(_on_ball_spawned)
		ball_node.ball_moved.connect(_on_ball_moved)
		ball_node.ball_disappeared.connect(_on_ball_disappeared)
		ball_detected = true
		current_status = Status.PLAYFUL

	elif not found_ball and ball_detected:
		ball_detected = false
		ball_position = null
		current_status = Status.IDLE
		pick_new_wander_target()  # Resume wandering when ball disappears
		start_idle_jump_timer()  # Restart jump timer when going back to idle

func _on_ball_spawned():
	current_status = Status.PLAYFUL

func _on_ball_moved(new_position):
	ball_position = new_position

func _on_ball_disappeared():
	ball_detected = false
	ball_position = null
	current_status = Status.IDLE
	pick_new_wander_target()  # Resume wandering when ball disappears
	start_idle_jump_timer()  # Restart jump timer when going back to idle

func apply_force_to_collided_object():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.get_parent().is_in_group("ball"):
			var force_x = self.velocity.x * BALL_HIT_FORCE_X_MULTIPLIER
			var force_y = BALL_HIT_FORCE_Y

			var ball_force = Vector2(force_x, force_y)
			collider.apply_impulse(ball_force)

		elif collider is RigidBody2D:
			collider.apply_impulse(Vector2(FORCE_ON_COLLISION * direction, 0))
