extends CharacterBody2D

@export var base_speed: float = 150.0
@export var boost_speed: float = 400.0
@export var brake_speed: float = 50.0
@export var steer_speed: float = 250.0

func _ready() -> void:
	# Tells Godot this is a top-down game so collisions work perfectly on all sides
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta: float) -> void:
	var current_forward_speed = base_speed
	
	# "ui_up" is the Up arrow, "ui_accept" is Spacebar
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_accept") or Input.is_physical_key_pressed(KEY_W):
		current_forward_speed = boost_speed
	elif Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		current_forward_speed = brake_speed

	# Move up the screen
	velocity.y = -current_forward_speed
	
	# Steer left and right
	var steering_input = Input.get_axis("ui_left", "ui_right")
	if Input.is_physical_key_pressed(KEY_A):
		steering_input = -1.0
	elif Input.is_physical_key_pressed(KEY_D):
		steering_input = 1.0
		
	velocity.x = steering_input * steer_speed

	# move_and_slide handles the static body wall collisions automatically
	move_and_slide()
