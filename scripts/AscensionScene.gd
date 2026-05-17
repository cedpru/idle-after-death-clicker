extends Control

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var rank_label = $MarginContainer/VBoxContainer/RankLabel
@onready var reset_button = $MarginContainer/VBoxContainer/ResetButton
@onready var bonus_label = Label.new() # We will add a bonus label

var target_score = 0.0
var current_score_display = 0.0
var score_counting = false
var final_rank = "Ame Perdue"
var permanent_multiplier = 0.0

func _ready():
	reset_button.pressed.connect(_on_reset_pressed)
	reset_button.modulate.a = 0
	rank_label.modulate.a = 0
	
	# Add bonus label
	bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_label.add_theme_font_size_override("font_size", 22)
	bonus_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	bonus_label.modulate.a = 0
	$MarginContainer/VBoxContainer.add_child(bonus_label)
	$MarginContainer/VBoxContainer.move_child(bonus_label, 3) # Place after Rank
	
	calculate_ascension()
	
	# Start score animation
	score_counting = true
	
	# Create some background sparkles (Emojis)
	for i in range(15):
		spawn_sparkle()

func _process(delta):
	if score_counting:
		var diff = target_score - current_score_display
		if diff > 1.0:
			current_score_display += max(diff * 2.0 * delta, 10.0 * delta)
			score_label.text = "Score Total : " + str(floor(current_score_display))
		else:
			current_score_display = target_score
			score_label.text = "Score Total : " + str(floor(current_score_display))
			score_counting = false
			reveal_rank()

func spawn_sparkle():
	var sparkle = Label.new()
	sparkle.text = ["✨", "🌟", "⭐", "👑"][randi() % 4]
	sparkle.add_theme_font_size_override("font_size", randi_range(20, 50))
	sparkle.position = Vector2(randf_range(0, size.x), size.y + 50)
	add_child(sparkle)
	
	var duration = randf_range(3.0, 7.0)
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property(sparkle, "position:y", -100, duration)
	t.tween_property(sparkle, "position:x", sparkle.position.x + randf_range(-100, 100), duration)
	t.tween_property(sparkle, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	t.chain().tween_callback(func():
		sparkle.queue_free()
		if is_inside_tree(): spawn_sparkle()
	)

func calculate_ascension():
	target_score = 0.0
	for life in Global.lives:
		target_score += life.get("richesse", 0)
		target_score += life.get("intelligence", 0)
		target_score += life.get("chance", 0)
		target_score += life.get("geographie", 0)
		target_score += life.get("beaute", 0)
		
	# Add death essence contribution
	target_score += Global.total_essence * 0.1
	
	# Determine rank
	final_rank = "Ame Perdue"
	if target_score > 50000: final_rank = "Dieu Suprême"
	elif target_score > 25000: final_rank = "Dieu"
	elif target_score > 10000: final_rank = "Archange"
	elif target_score > 5000: final_rank = "Esprit Supérieur"
	elif target_score > 2000: final_rank = "Héros Céleste"
	elif target_score > 1000: final_rank = "Fantôme"
	
	# Bonus math: every 1000 score = +10% multiplier
	permanent_multiplier = floor(target_score / 100.0) # 100 score = 1%
	bonus_label.text = "Bonus Permanent : +" + str(permanent_multiplier) + "% Essence"

func reveal_rank():
	rank_label.text = "Rang : " + final_rank
	rank_label.scale = Vector2(3, 3)
	rank_label.pivot_offset = Vector2(rank_label.size.x / 2.0, rank_label.size.y / 2.0)
	
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property(rank_label, "modulate:a", 1.0, 0.4)
	t.tween_property(rank_label, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	t.chain().tween_property(bonus_label, "modulate:a", 1.0, 0.5)
	t.chain().tween_property(reset_button, "modulate:a", 1.0, 1.0)

func _on_reset_pressed():
	# Actually apply the bonus in Global
	Global.ascension_multiplier += (permanent_multiplier / 100.0)
	Global.reset_for_ascension()
	get_tree().change_scene_to_file("res://scenes/DeathScene.tscn")
