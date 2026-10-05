extends CharacterBody2D

@export var drive_speed: float = 100.0
@export var side_speed: float = 50.0

var side_direction: float = 1.0 

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	# Randomize starting direction (Left or Right)
	var directions = [-1.0, 1.0]
	side_direction = directions.pick_random()

func _physics_process(_delta: float) -> void:
	# A negative Y value moves the car UP the screen
	velocity.y = -abs(drive_speed) 
	
	# Left and right movement
	velocity.x = side_speed * side_direction

	if move_and_slide():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Reverse direction only when hitting the side walls
			if collider.name == "wall" or collider.name == "wall2":
				side_direction *= -1.0
				break # Only bounce once per frame

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "PlayerCar":
		if has_node("/root/GameManager"):
			get_node("/root/GameManager").trigger_death()
		else:
			get_tree().reload_current_scene()
