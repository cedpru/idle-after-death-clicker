extends Control

@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel
@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var rank_label = $MarginContainer/VBoxContainer/RankLabel
@onready var reset_button = $MarginContainer/VBoxContainer/ResetButton
@onready var background = $Background

var bonus_label = Label.new()
var target_score = 0.0
var current_score_display = 0.0
var score_counting = false
var final_rank = "Âme Perdue"
var permanent_multiplier = 0.0

# Dynamic Ending Variables
var ending_title = ""
var ending_desc = ""
var ending_icon = ""
var ending_color = Color.WHITE

func _ready():
	reset_button.pressed.connect(_on_reset_pressed)
	reset_button.modulate.a = 0
	rank_label.modulate.a = 0
	
	# Configure Background Anchor/Pivot for Breathing Animation
	background.pivot_offset = Vector2(189, 336)
	
	# Style Ascension Button (Radiant Gold)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("#ffb703") # Golden amber
	btn_style.corner_radius_top_left = 12
	btn_style.corner_radius_top_right = 12
	btn_style.corner_radius_bottom_left = 12
	btn_style.corner_radius_bottom_right = 12
	reset_button.add_theme_stylebox_override("normal", btn_style)
	
	var btn_style_hover = btn_style.duplicate()
	btn_style_hover.bg_color = Color("#fb8500")
	reset_button.add_theme_stylebox_override("hover", btn_style_hover)
	
	var btn_style_pressed = btn_style.duplicate()
	btn_style_pressed.bg_color = Color("#d00000")
	reset_button.add_theme_stylebox_override("pressed", btn_style_pressed)
	
	reset_button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.15)) # Dark text for contrast
	reset_button.add_theme_font_size_override("font_size", 16)
	reset_button.text = "Recommencer le Cycle Éternel"
	
	# Hide default layout spacer to inject our gorgeous list card
	if has_node("MarginContainer/VBoxContainer/Spacer"):
		$MarginContainer/VBoxContainer/Spacer.visible = false
	
	# Configure Title and Score Labels for readability
	title_label.add_theme_color_override("font_color", Color("#ffb703"))
	title_label.add_theme_font_size_override("font_size", 28)
	
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_label.add_theme_font_size_override("font_size", 20)
	
	# Initialize Bonus Label
	bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_label.add_theme_font_size_override("font_size", 16)
	bonus_label.add_theme_color_override("font_color", Color("#4ade80")) # Glowing mint green
	bonus_label.modulate.a = 0
	$MarginContainer/VBoxContainer.add_child(bonus_label)
	$MarginContainer/VBoxContainer.move_child(bonus_label, 3)
	
	# CALCULATE averages, score & endings
	calculate_ascension_and_endings()
	
	# Build and inject scrollable 10-life report
	build_10_lives_report()
	
	# Start score counter animation
	score_counting = true
	
	# Spawn ambient sparkles
	for i in range(12):
		spawn_sparkle()

func _process(delta):
	# Gentle breathing scale animation for background
	var time = Time.get_ticks_msec() / 1000.0
	background.scale = Vector2(1.02 + sin(time * 0.15) * 0.02, 1.02 + sin(time * 0.15) * 0.02)
	
	if score_counting:
		var diff = target_score - current_score_display
		if diff > 1.0:
			current_score_display += max(diff * 4.0 * delta, 25.0 * delta)
			score_label.text = "Score Éthérique Total : " + str(floor(current_score_display))
		else:
			current_score_display = target_score
			score_label.text = "Score Éthérique Total : " + str(floor(current_score_display))
			score_counting = false
			reveal_rank_and_ending()

func spawn_sparkle():
	var sparkle = Label.new()
	sparkle.text = ["✨", "🌟", "⭐", "💫"][randi() % 4]
	sparkle.add_theme_font_size_override("font_size", randi_range(16, 32))
	sparkle.position = Vector2(randf_range(0, size.x), size.y + 40)
	add_child(sparkle)
	
	var duration = randf_range(4.0, 8.0)
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property(sparkle, "position:y", -100, duration)
	t.tween_property(sparkle, "position:x", sparkle.position.x + randf_range(-80, 80), duration)
	t.tween_property(sparkle, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	t.chain().tween_callback(func():
		sparkle.queue_free()
		if is_inside_tree(): spawn_sparkle()
	)

func calculate_ascension_and_endings():
	target_score = 0.0
	var avg_richesse = 0.0
	var avg_intelligence = 0.0
	var avg_chance = 0.0
	var avg_geographie = 0.0
	var avg_beaute = 0.0
	
	for life in Global.lives:
		var r = life.get("richesse", 0.0)
		var i = life.get("intelligence", 0.0)
		var c = life.get("chance", 0.0)
		var g = life.get("geographie", 0.0)
		var b = life.get("beaute", 0.0)
		
		target_score += r + i + c + g + b
		avg_richesse += r
		avg_intelligence += i
		avg_chance += c
		avg_geographie += g
		avg_beaute += b
		
	# Add death essence contribution
	target_score += Global.total_essence * 0.15
	
	var count = max(Global.lives.size(), 1.0)
	avg_richesse /= count
	avg_intelligence /= count
	avg_chance /= count
	avg_geographie /= count
	avg_beaute /= count
	
	# Determine dominant average stat
	var averages = {
		"richesse": avg_richesse,
		"intelligence": avg_intelligence,
		"chance": avg_chance,
		"geographie": avg_geographie,
		"beaute": avg_beaute
	}
	var best_avg = "richesse"
	var max_avg = avg_richesse
	for s in averages:
		if averages[s] > max_avg:
			max_avg = averages[s]
			best_avg = s
			
	# NARRATIVE PROCEDURAL MULTIPLE ENDINGS (Ange, Démon, Archimage, etc.)
	if avg_richesse > 55.0 and avg_beaute < 35.0:
		ending_title = "😈 SEIGNEUR DES OMBRES (DÉMON)"
		ending_desc = "Votre soif intarissable d'or terrestre et votre mépris de l'art et du cœur vous ont condamné à régner sur l'abîme."
		ending_icon = "😈"
		ending_color = Color("#e63946") # Crimson Demon Red
	elif avg_beaute > 52.0 and avg_chance > 48.0:
		ending_title = "👼 SUPRÊME ANGE CÉLESTE (ANGE)"
		ending_desc = "Votre magnificence absolue et votre chance providentielle ont purifié le vide. Vous devenez le guide céleste des âmes."
		ending_icon = "👼"
		ending_color = Color("#00f5d4") # Heavenly Aquamarine
	elif best_avg == "intelligence":
		ending_title = "🧙 ARCHIMAGE DU SACRÉ (MAGE)"
		ending_desc = "Vos savantes théories posthumes ont percé les équations secrètes du vide cosmique. Vous fusionnez avec la raison pure."
		ending_icon = "🧙"
		ending_color = Color("#9b5de5") # Cosmic Violet
	elif best_avg == "richesse":
		ending_title = "👑 SOUVERAIN DE L'ABONDANCE"
		ending_desc = "Vous transmutez les poussières cosmiques en pièces célestes. La fortune éternelle du vide est sous votre empire."
		ending_icon = "👑"
		ending_color = Color("#ffb703") # Gold Imperial
	elif best_avg == "geographie":
		ending_title = "🌌 SEIGNEUR MULTIDIMENSIONNEL"
		ending_desc = "Les passages dimensionnels de l'espace-temps n'ont plus d'inconnu. Vous tracez les routes de l'Au-delà."
		ending_icon = "🌌"
		ending_color = Color("#00b4d8") # Astral Blue
	else:
		ending_title = "👻 L'ÂME ÉTHÉRÉE ÉQUILIBRÉE"
		ending_desc = "Ayant vécu 10 incarnations diverses sans attache extrême, vous conservez votre libre arbitre souverain dans le cycle éternel."
		ending_icon = "👻"
		ending_color = Color("#e2e8f0") # Astral Silver
		
	# Determine rank title based on total score
	final_rank = "Ame Vagabonde"
	if target_score > 8000: final_rank = "Divinité Omnisciente"
	elif target_score > 5000: final_rank = "Demi-Dieu stellaire"
	elif target_score > 3000: final_rank = "Archange Éthéré"
	elif target_score > 1500: final_rank = "Esprit Majeur"
	elif target_score > 800: final_rank = "Héros Céleste"
	
	# 100 score = +1% multiplier
	permanent_multiplier = floor(target_score / 80.0) 
	bonus_label.text = "Bonus Permanent : +" + str(permanent_multiplier) + "% Essence"

func build_10_lives_report():
	# Visual Glassmorphic Card Container for 10-life nostalgic recap list
	var report_card = PanelContainer.new()
	report_card.custom_minimum_size = Vector2(0, 220)
	report_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.06, 0.06, 0.12, 0.85)
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 4
	card_style.border_color = Color("#ffb703") # Gold frame
	card_style.corner_radius_top_left = 16
	card_style.corner_radius_top_right = 16
	card_style.corner_radius_bottom_left = 16
	card_style.corner_radius_bottom_right = 16
	card_style.content_margin_left = 12
	card_style.content_margin_right = 12
	card_style.content_margin_top = 12
	card_style.content_margin_bottom = 12
	report_card.add_theme_stylebox_override("panel", card_style)
	
	var vbox_card = VBoxContainer.new()
	vbox_card.add_theme_constant_override("separation", 10)
	report_card.add_child(vbox_card)
	
	var card_title = Label.new()
	card_title.text = "📜 RÉCIT DES 10 INCARNATIONS"
	card_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_title.add_theme_font_size_override("font_size", 14)
	card_title.add_theme_color_override("font_color", Color("#ffb703"))
	vbox_card.add_child(card_title)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_card.add_child(scroll)
	
	var scroll_vbox = VBoxContainer.new()
	scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(scroll_vbox)
	
	# Generate recap line for each life lived
	var index = 1
	for life in Global.lives:
		var best = "richesse"
		var max_val = life.get("richesse", 0.0)
		for s in ["intelligence", "chance", "geographie", "beaute"]:
			if life.get(s, 0.0) > max_val:
				max_val = life.get(s, 0.0)
				best = s
		
		var life_type = "Modeste"
		var emoji = "🌾"
		if max_val >= 30.0:
			if best == "richesse": 
				life_type = "Milliardaire"
				emoji = "💰"
			elif best == "intelligence": 
				life_type = "Savant"
				emoji = "🧠"
			elif best == "chance": 
				life_type = "Veinard"
				emoji = "🍀"
			elif best == "geographie": 
				life_type = "Explorateur"
				emoji = "🗺️"
			elif best == "beaute": 
				life_type = "Merveille"
				emoji = "✨"
				
		var life_label = Label.new()
		life_label.text = "Vie #" + str(index) + " : " + emoji + " " + life_type + " (" + str(floor(max_val)) + "%)\n"
		
		var death_reason = "Fermier malchanceux foudroyé devant ses navets."
		if max_val >= 30.0:
			if best == "richesse": death_reason = "Glissade dans sa piscine de champagne."
			elif best == "intelligence": death_reason = "Écrasé sous un piano tombé du ciel."
			elif best == "chance": death_reason = "Étouffé par un bretzel porte-bonheur."
			elif best == "geographie": death_reason = "Perdu à jamais dans sa propre cave."
			elif best == "beaute": death_reason = "Écrasé sous les lettres d'amour passionnées."
			
		life_label.text += "👉 Décès : " + death_reason
		life_label.add_theme_font_size_override("font_size", 11)
		life_label.add_theme_color_override("font_color", Color("#cbd5e1"))
		life_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		scroll_vbox.add_child(life_label)
		
		var sep = ColorRect.new()
		sep.custom_minimum_size = Vector2(0, 1)
		sep.color = Color(0.2, 0.2, 0.3, 0.4)
		scroll_vbox.add_child(sep)
		
		index += 1
		
	# Insert the report card inside main viewport vbox
	$MarginContainer/VBoxContainer.add_child(report_card)
	$MarginContainer/VBoxContainer.move_child(report_card, 3)

func reveal_rank_and_ending():
	# Display dynamic narrative ending
	rank_label.text = ending_icon + " FIN : " + ending_title + " (" + final_rank + ")\n"
	rank_label.text += ending_desc
	rank_label.add_theme_color_override("font_color", ending_color)
	rank_label.add_theme_font_size_override("font_size", 12)
	rank_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	rank_label.scale = Vector2(1.8, 1.8)
	rank_label.pivot_offset = Vector2(rank_label.size.x / 2.0, rank_label.size.y / 2.0)
	
	var t = get_tree().create_tween().set_parallel(true)
	t.tween_property(rank_label, "modulate:a", 1.0, 0.5)
	t.tween_property(rank_label, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	t.chain().tween_property(bonus_label, "modulate:a", 1.0, 0.4)
	t.chain().tween_property(reset_button, "modulate:a", 1.0, 0.6)

func _on_reset_pressed():
	Global.play_sfx("buy")
	Global.ascension_multiplier += (permanent_multiplier / 100.0)
	Global.reset_for_ascension()
	get_tree().change_scene_to_file("res://scenes/DeathScene.tscn")
