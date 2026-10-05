extends CharacterBody2D

@export var base_speed: float = 30.0
@export var vertical_wander: float = 15.0

var y_direction: float = 0.0
var wander_timer: float = 0.0
var current_speed: float = 30.0

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	# Play animation if it exists
	var sprite = get_node_or_null("Sprite2D")
	if sprite and sprite is AnimatedSprite2D:
		sprite.play("default")
		
	# Dynamically add a Hitbox to detect collisions with the player
	var hitbox = Area2D.new()
	hitbox.name = "Hitbox"
	
	var collision = CollisionShape2D.new()
	
	# Copy and slightly enlarge the existing collision shape so the hitbox wraps it perfectly
	var physical_col = get_node_or_null("CollisionShape2D")
	if physical_col and physical_col.shape:
		var shape_copy = physical_col.shape.duplicate()
		if shape_copy is RectangleShape2D:
			shape_copy.size += Vector2(20, 20)
		elif shape_copy is CapsuleShape2D:
			shape_copy.radius += 10.0
			shape_copy.height += 20.0
		
		collision.shape = shape_copy
		collision.position = physical_col.position
	else:
		var shape = RectangleShape2D.new()
		shape.size = Vector2(30, 60)
		collision.shape = shape
		
	hitbox.add_child(collision)
	add_child(hitbox)
	
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# Randomize initial speed and direction
	current_speed = base_speed + randf_range(-5.0, 5.0)
	y_direction = randf_range(-1.0, 1.0)

func _physics_process(delta: float) -> void:
	# Random wander logic for the Y axis
	wander_timer -= delta
	if wander_timer <= 0:
		wander_timer = randf_range(0.5, 1.5)
		y_direction = randf_range(-1.0, 1.0)
		current_speed = base_speed + randf_range(-5.0, 10.0)
		
	# Move slowly from left to right (positive X)
	velocity.x = current_speed
	
	# Add the slight random vertical movement
	velocity.y = y_direction * vertical_wander
	
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if "PlayerCar" in body.name:
		if has_node("/root/GameManager"):
			get_node("/root/GameManager").add_kill()
		queue_free()
