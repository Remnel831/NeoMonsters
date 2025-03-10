extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -800.0

@onready var _animated_sprite_body = get_node("Body")
@onready var _animated_sprite_face = get_node("Face")
@onready var jump_Sound = get_node("JumpSound")
@onready var camera = $Camera2D  # Reference to the attached Camera2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_animated_sprite_body.play("Jump")
		jump_Sound.play()

		
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if Input.is_action_just_pressed("ui_left"):
				_animated_sprite_body.play("Walk_Left")
				_animated_sprite_face.play("Move_Left_Face")
		elif Input.is_action_just_pressed("ui_right"):
				_animated_sprite_body.play("Walk_Right")
				_animated_sprite_face.play("Move_Right_Face")
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		_animated_sprite_body.play("Idle_Animation")
		_animated_sprite_face.play("Idle_Face")
	move_and_slide()
	
	# Ensure the camera follows the player
	if camera:
		camera.global_position = global_position

func _process(_delta):
	$Points.text = "COINS: " + str(Global.coinsCollected) + " / 10" + "\nPOINTS: " + str(Global.point)


func _on_exit_btn_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main/main.tscn")
