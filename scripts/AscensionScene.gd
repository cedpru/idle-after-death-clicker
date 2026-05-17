extends Control

@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var rank_label = $MarginContainer/VBoxContainer/RankLabel
@onready var reset_button = $MarginContainer/VBoxContainer/ResetButton

func _ready():
	reset_button.pressed.connect(_on_reset_pressed)
	calculate_ascension()

func calculate_ascension():
	var total_score = 0.0
	
	for life in Global.lives:
		total_score += life["richesse"]
		total_score += life["intelligence"]
		total_score += life["chance"]
		total_score += life["geographie"]
		total_score += life["beaute"]
		
	# Add death essence contribution
	total_score += Global.total_essence * 0.1
	
	score_label.text = "Score Total : " + str(floor(total_score))
	
	var rank = "Ame Perdue"
	if total_score > 10000:
		rank = "Dieu"
	elif total_score > 5000:
		rank = "Archange"
	elif total_score > 2000:
		rank = "Esprit Supérieur"
	elif total_score > 1000:
		rank = "Fantôme"
		
	rank_label.text = "Rang : " + rank

func _on_reset_pressed():
	Global.reset_for_ascension()
	get_tree().change_scene_to_file("res://scenes/DeathScene.tscn")
