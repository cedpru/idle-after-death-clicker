extends Control

@onready var stats_container = $MarginContainer/VBoxContainer/StatsContainer
@onready var end_life_button = $MarginContainer/VBoxContainer/EndLifeButton
@onready var avatar_label = $MarginContainer/VBoxContainer/AvatarLabel

func _ready():
	end_life_button.pressed.connect(_on_end_life_pressed)
	end_life_button.modulate.a = 0
	avatar_label.modulate.a = 0
	
	if Global.lives.size() > 0:
		var current_life = Global.lives[-1]
		
		var best_stat = "richesse"
		var max_val = current_life["richesse"]
		for stat in ["intelligence", "chance", "geographie", "beaute"]:
			if current_life[stat] > max_val:
				max_val = current_life[stat]
				best_stat = stat
				
		var desc_label = $MarginContainer/VBoxContainer/DescLabel
		desc_label.modulate.a = 0
		
		if max_val < 30:
			avatar_label.text = "🧑‍🌾"
			desc_label.text = _get_random_phrase("pauvre")
		else:
			if best_stat == "richesse": 
				avatar_label.text = "🤴"
				desc_label.text = _get_random_phrase("richesse")
			elif best_stat == "intelligence": 
				avatar_label.text = "🧙"
				desc_label.text = _get_random_phrase("intelligence")
			elif best_stat == "chance": 
				avatar_label.text = "🎰"
				desc_label.text = _get_random_phrase("chance")
			elif best_stat == "geographie": 
				avatar_label.text = "🌍"
				desc_label.text = _get_random_phrase("geographie")
			elif best_stat == "beaute": 
				avatar_label.text = "🧝"
				desc_label.text = _get_random_phrase("beaute")
			
		# Animate avatar and desc
		avatar_label.scale = Vector2(0.5, 0.5)
		avatar_label.pivot_offset = Vector2(avatar_label.size.x / 2.0, avatar_label.size.y / 2.0)
		var t_avatar = get_tree().create_tween().set_parallel(true)
		t_avatar.tween_property(avatar_label, "modulate:a", 1.0, 0.5)
		t_avatar.tween_property(avatar_label, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BOUNCE)
		t_avatar.tween_property(desc_label, "modulate:a", 1.0, 0.5).set_delay(0.2)
		
		display_stat("Richesse", current_life["richesse"], 0.4)
		display_stat("Intelligence", current_life["intelligence"], 0.7)
		display_stat("Chance", current_life["chance"], 1.0)
		display_stat("Géographie", current_life["geographie"], 1.3)
		display_stat("Beauté", current_life["beaute"], 1.6)
		
		var tween = get_tree().create_tween()
		tween.tween_property(end_life_button, "modulate:a", 1.0, 0.8).set_delay(2.2)

func _get_random_phrase(category: String) -> String:
	var phrases = {
		"richesse": [
			"Vous avez passé votre vie à nager dans l'or, mais l'argent n'achète pas l'immortalité.",
			"Marchand impitoyable, vous avez tout acheté... sauf votre santé.",
			"Une vie de milliardaire, terminée par une glissade ridicule dans votre piscine de champagne."
		],
		"intelligence": [
			"Le plus grand savant de l'époque... qui n'a pas vu le piano tomber du 3ème étage.",
			"Génie absolu, vous avez percé les secrets de l'univers avant de mourir d'un rhume.",
			"Vous avez inventé le voyage dans le temps, mais l'avez testé au bord d'une falaise."
		],
		"chance": [
			"Gagnant du loto à trois reprises, vous vous êtes étouffé avec un bretzel porte-bonheur.",
			"Une vie entière à survivre par miracle, jusqu'à cette attaque de pigeon.",
			"La chance vous a souri si longtemps que la faucheuse a dû tricher pour vous avoir."
		],
		"geographie": [
			"Explorateur légendaire, vous avez fait le tour du monde pour vous perdre dans votre cave.",
			"Vous avez gravi l'Everest, mais trébuché sur le trottoir en rentrant chez vous.",
			"Cartographe de génie, vous avez été avalé par des sables mouvants non répertoriés."
		],
		"beaute": [
			"Votre charme a brisé des cœurs, jusqu'à ce que le vôtre lâche bêtement.",
			"On a sculpté des statues de vous, dommage qu'une d'elles vous soit tombée dessus.",
			"Star adorée, vous êtes mort écrasé sous les lettres passionnées de vos fans."
		],
		"pauvre": [
			"Une vie morne et sans éclat. Vous avez glissé sur une flaque et personne ne l'a remarqué.",
			"Vous n'aviez rien, et vous n'avez laissé derrière vous qu'un râteau cassé.",
			"Fermier malchanceux, foudroyé en regardant pousser vos navets."
		]
	}
	
	if phrases.has(category):
		var list = phrases[category]
		return list[randi() % list.size()]
	return "Une vie tout à fait normale qui s'est terminée normalement."

func display_stat(stat_name: String, value: float, delay: float):
	var label = Label.new()
	label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	label.add_theme_font_size_override("font_size", 24)
	label.text = stat_name + " : " + str(floor(value))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Prepare for animation
	label.modulate.a = 0.0
	stats_container.add_child(label)
	
	# Add slight vertical offset after it's in the tree to slide it
	await get_tree().process_frame
	var original_y = label.position.y
	label.position.y += 20
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(label, "modulate:a", 1.0, 0.5).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", original_y, 0.5).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_end_life_pressed():
	# Transition back to DeathScene
	get_tree().change_scene_to_file("res://scenes/DeathScene.tscn")
