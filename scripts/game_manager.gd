extends Node

var score: int = 0
var score_label: Label
var start_panel: ColorRect
var end_panel: ColorRect
var end_label1: Label
var end_label2: Label
var replay_button: Button
var active_tween: Tween
var canvas: CanvasLayer
var fade_rect: ColorRect
var is_shaking: bool = false
var shake_intensity: float = 0.0
var original_camera_offset: Vector2 = Vector2.ZERO
var player_camera: Camera2D

var bgm_player: AudioStreamPlayer
var crash_player: AudioStreamPlayer
var death_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Run even when game is paused
	call_deferred("_setup_ui")

func _process(delta: float) -> void:
	if is_shaking and is_instance_valid(player_camera):
		player_camera.offset = original_camera_offset + Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)

func _setup_ui() -> void:
	# Audio setup
	bgm_player = AudioStreamPlayer.new()
	var bgm_stream = load("res://assets/sounds/background.mp3")
	if bgm_stream:
		bgm_stream.loop = true
	bgm_player.stream = bgm_stream
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	bgm_player.volume_db = linear_to_db(0.7)
	add_child(bgm_player)
	
	crash_player = AudioStreamPlayer.new()
	crash_player.stream = load("res://assets/sounds/crash.mp3")
	crash_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(crash_player)
	
	death_player = AudioStreamPlayer.new()
	death_player.stream = load("res://assets/sounds/death.mp3")
	death_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(death_player)
	
	var custom_font = load("res://assets/LibreCaslonCondensed-Italic.ttf")
	
	canvas = CanvasLayer.new()
	canvas.layer = 100 # Make sure UI is on top
	add_child(canvas)
	
	# Fade Rect
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0
	canvas.add_child(fade_rect)
	
	# Score Label
	score_label = Label.new()
	score_label.text = "Kill Count: 0"
	score_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 20)
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color.RED)
	score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	score_label.add_theme_constant_override("outline_size", 6)
	canvas.add_child(score_label)
	
	# Start Panel
	start_panel = ColorRect.new()
	start_panel.color = Color(0, 0, 0, 0.6)
	start_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(start_panel)
	
	var play_button = Button.new()
	play_button.text = "PLAY"
	play_button.add_theme_font_size_override("font_size", 64)
	play_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	play_button.grow_horizontal = Control.GROW_DIRECTION_BOTH
	play_button.grow_vertical = Control.GROW_DIRECTION_BOTH
	play_button.pressed.connect(_on_play_pressed)
	start_panel.add_child(play_button)
	
	# End Panel
	end_panel = ColorRect.new()
	end_panel.color = Color(0, 0, 0, 0.9)
	end_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	end_panel.hide()
	canvas.add_child(end_panel)
	
	end_label1 = Label.new()
	end_label1.add_theme_font_size_override("font_size", 48)
	if custom_font:
		end_label1.add_theme_font_override("font", custom_font)
	end_label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label1.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	end_label1.grow_horizontal = Control.GROW_DIRECTION_BOTH
	end_label1.grow_vertical = Control.GROW_DIRECTION_BOTH
	end_panel.add_child(end_label1)
	
	end_label2 = Label.new()
	end_label2.text = "was this even worhtit?"
	end_label2.add_theme_font_size_override("font_size", 48)
	if custom_font:
		end_label2.add_theme_font_override("font", custom_font)
	end_label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label2.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	end_label2.grow_horizontal = Control.GROW_DIRECTION_BOTH
	end_label2.grow_vertical = Control.GROW_DIRECTION_BOTH
	end_panel.add_child(end_label2)
	
	replay_button = Button.new()
	replay_button.text = "REPLAY"
	replay_button.add_theme_font_size_override("font_size", 48)
	replay_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 100)
	replay_button.grow_horizontal = Control.GROW_DIRECTION_BOTH
	replay_button.grow_vertical = Control.GROW_DIRECTION_BOTH
	replay_button.position.y -= 100 # move up a bit from bottom
	replay_button.pressed.connect(_on_replay_pressed)
	end_panel.add_child(replay_button)
	
	_hook_up_scene()

func _hook_up_scene() -> void:
	score = 0
	_update_score()
	
	# Freeze the game
	get_tree().paused = true
	start_panel.show()
	end_panel.hide()
	replay_button.hide()
	
	var scene = get_tree().current_scene
	if not scene: return
	
	var end_area = scene.get_node_or_null("End")
	if end_area and end_area is Area2D:
		if not end_area.body_entered.is_connected(_on_end_reached):
			end_area.body_entered.connect(_on_end_reached)

func trigger_death() -> void:
	if bgm_player:
		bgm_player.stop()
	if crash_player:
		crash_player.play()
		
	get_tree().paused = true
	var scene = get_tree().current_scene
	if scene:
		var player = scene.get_node_or_null("PlayerCar")
		if player:
			player_camera = player.get_node_or_null("Camera2D")
			if player_camera:
				original_camera_offset = player_camera.offset
				
	is_shaking = true
	shake_intensity = 20.0
	
	if active_tween:
		active_tween.kill()
	active_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Fade out
	active_tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	
	# Once faded out, stop shaking, reload scene
	active_tween.tween_callback(func():
		is_shaking = false
		if is_instance_valid(player_camera):
			player_camera.offset = original_camera_offset
		get_tree().reload_current_scene()
	)
	
	active_tween.tween_interval(0.1)
	
	# Setup UI for newly reloaded scene
	active_tween.tween_callback(func():
		_hook_up_scene()
	)
	
	# Fade back in
	active_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)

func add_kill() -> void:
	score += 1
	_update_score()
	if death_player:
		death_player.play()

func _update_score() -> void:
	if score_label:
		score_label.text = "Kill Count: %d" % score

func _on_play_pressed() -> void:
	start_panel.hide()
	get_tree().paused = false
	if bgm_player and not bgm_player.playing:
		bgm_player.play()

func _on_end_reached(body: Node2D) -> void:
	if not "PlayerCar" in body.name:
		return
		
	# Prevent triggering multiple times
	var scene = get_tree().current_scene
	var end_area = scene.get_node_or_null("End")
	if end_area and end_area is Area2D:
		end_area.set_deferred("monitoring", false)
		
	# Pause game again
	get_tree().paused = true
	
	end_panel.show()
	end_panel.modulate.a = 0.0
	
	end_label1.text = "Hell Yeah!! you have killed %d Kids" % score
	end_label1.modulate.a = 0.0
	end_label2.modulate.a = 0.0
	replay_button.hide()
	
	if active_tween:
		active_tween.kill()
	active_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# Fade in end panel background
	active_tween.tween_property(end_panel, "modulate:a", 1.0, 1.0)
	
	# Fade in label 1
	active_tween.tween_property(end_label1, "modulate:a", 1.0, 1.0)
	
	# Wait 2 seconds
	active_tween.tween_interval(2.0)
	
	# Fade out label 1
	active_tween.tween_property(end_label1, "modulate:a", 0.0, 1.0)
	
	# Fade in label 2
	active_tween.tween_property(end_label2, "modulate:a", 1.0, 1.0)
	
	# Wait 1 second
	active_tween.tween_interval(1.0)
	
	# Show replay button
	active_tween.tween_callback(func(): replay_button.show())

func _on_replay_pressed() -> void:
	if bgm_player:
		bgm_player.stop()
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	# Wait for the scene to reload, then hook it up again
	await get_tree().process_frame
	await get_tree().process_frame
	_hook_up_scene()
