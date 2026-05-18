extends Control

@onready var background = $Background
@onready var stats_container = $MarginContainer/VBoxContainer/StatsContainer
@onready var end_life_button = $MarginContainer/VBoxContainer/EndLifeButton
@onready var avatar_label = $MarginContainer/VBoxContainer/AvatarLabel
@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label = $MarginContainer/VBoxContainer/DescLabel

func _ready():
	end_life_button.pressed.connect(_on_end_life_pressed)
	end_life_button.modulate.a = 0
	avatar_label.modulate.a = 0
	avatar_label.add_theme_font_size_override("font_size", 80)
	desc_label.modulate.a = 0
	
	# Configure Background Anchor/Pivot
	background.pivot_offset = Vector2(189, 336)
	
	# Create Glassmorphic card styling dynamically to ensure 100% contrast and readability
	var card_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.12, 0.85) # High opacity transluscent dark purple card
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 4
	style.border_color = Color("#8338ec") # Vibrant neon purple border
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.content_margin_left = 15
	style.content_margin_right = 15
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	card_panel.add_theme_stylebox_override("panel", style)
	
	# Reparent VBoxContainer inside the gorgeous new Glassmorphic Panel
	var vbox = $MarginContainer/VBoxContainer
	$MarginContainer.remove_child(vbox)
	$MarginContainer.add_child(card_panel)
	card_panel.add_child(vbox)
	
	# Style Labels for ultimate legibility
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	desc_label.add_theme_color_override("font_color", Color("#cbd5e1")) # Silver gray
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Style Return/Rebirth Button
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("#ef233c") # High-energy glowing crimson
	btn_style.corner_radius_top_left = 12
	btn_style.corner_radius_top_right = 12
	btn_style.corner_radius_bottom_left = 12
	btn_style.corner_radius_bottom_right = 12
	end_life_button.add_theme_stylebox_override("normal", btn_style)
	
	var btn_style_hover = btn_style.duplicate()
	btn_style_hover.bg_color = Color("#d90429")
	end_life_button.add_theme_stylebox_override("hover", btn_style_hover)
	
	var btn_style_pressed = btn_style.duplicate()
	btn_style_pressed.bg_color = Color("#b3001e")
	end_life_button.add_theme_stylebox_override("pressed", btn_style_pressed)
	
	end_life_button.add_theme_color_override("font_color", Color.WHITE)
	end_life_button.add_theme_font_size_override("font_size", 16)
	
	# DYNAMIC PROCEDURAL LIFETIME SELECTION & BACKGROUND MATCHING
	if Global.lives.size() > 0:
		var current_life = Global.lives[-1]
		
		var best_stat = "richesse"
		var max_val = current_life["richesse"]
		for stat in ["intelligence", "chance", "geographie", "beaute"]:
			if current_life[stat] > max_val:
				max_val = current_life[stat]
				best_stat = stat
		
		# Set avatar visual dynamically based on stats (Using full-color emojis supported natively via system font fallback)
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
		
		# DYNAMIC THEMED BACKGROUND ASSIGNMENT
		var bg_path = "res://assets/life_background.jpg" # Default sunset city
		if max_val >= 30:
			if best_stat == "richesse":
				bg_path = "res://assets/life_background_rich.jpg"
			elif best_stat == "intelligence":
				bg_path = "res://assets/life_background_smart.jpg"
			elif best_stat == "beaute":
				bg_path = "res://assets/life_background_beauty.jpg"
		
		if FileAccess.file_exists(bg_path):
			background.texture = load(bg_path)
			
		# Animate avatar and desc
		avatar_label.scale = Vector2(0.3, 0.3)
		avatar_label.pivot_offset = Vector2(avatar_label.size.x / 2.0, avatar_label.size.y / 2.0)
		
		var t_avatar = get_tree().create_tween().set_parallel(true)
		t_avatar.tween_property(avatar_label, "modulate:a", 1.0, 0.4)
		t_avatar.tween_property(avatar_label, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t_avatar.tween_property(desc_label, "modulate:a", 1.0, 0.4).set_delay(0.1)
		
		# Snappy stats list reveals to avoid user waiting
		display_stat("💰 Richesse", current_life["richesse"], 0.1)
		display_stat("🧠 Intelligence", current_life["intelligence"], 0.2)
		display_stat("🍀 Chance", current_life["chance"], 0.3)
		display_stat("🗺️ Géographie", current_life["geographie"], 0.4)
		display_stat("✨ Beauté", current_life["beaute"], 0.5)
		
		# Reveal action button quickly
		var tween = get_tree().create_tween()
		tween.tween_property(end_life_button, "modulate:a", 1.0, 0.4).set_delay(0.6)

func _process(_delta: float):
	# Gentle slow breathing animation to make the background feel alive and cosmic
	var time = Time.get_ticks_msec() / 1000.0
	background.scale = Vector2(1.03 + sin(time * 0.2) * 0.03, 1.03 + sin(time * 0.2) * 0.03)

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
	label.add_theme_color_override("font_color", Color("#f8f9fa")) # Bright readable off-white
	label.add_theme_font_size_override("font_size", 16)
	label.text = stat_name + " : " + str(floor(value)) + " %"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Prepare for animation
	label.modulate.a = 0.0
	stats_container.add_child(label)
	
	# Add slight vertical offset after it's in the tree to slide it
	await get_tree().process_frame
	var original_y = label.position.y
	label.position.y += 12
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(label, "modulate:a", 1.0, 0.3).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", original_y, 0.3).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_end_life_pressed():
	Global.play_sfx("buy")
	get_tree().change_scene_to_file("res://scenes/DeathScene.tscn")
