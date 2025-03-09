extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -800.0

@onready var camera = $Camera2D  # Reference to the attached Camera2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# Ensure the camera follows the player
	if camera:
		camera.global_position = global_position

func _process(_delta):
	$Points.text = "COINS: " + str(Global.coinsCollected) + " / 10" + "\nPOINTS: " + str(Global.point)


func _on_exit_btn_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main/main.tscn")
