extends Control

@onready var stats_label = $MarginContainer/VBoxContainer/StatsLabel
@onready var level_progress = $MarginContainer/VBoxContainer/LevelProgress
@onready var click_button = $MarginContainer/VBoxContainer/ClickButton
@onready var upgrades_container = $MarginContainer/VBoxContainer/ScrollContainer/UpgradesContainer
@onready var rebirth_button = $MarginContainer/VBoxContainer/RebirthButton
@onready var settings_button = $SettingsButton
@onready var settings_panel = $SettingsPanel
@onready var sfx_check = $SettingsPanel/CenterContainer/VBoxContainer/SFXCheck
@onready var music_check = $SettingsPanel/CenterContainer/VBoxContainer/MusicCheck
@onready var debug_button = $SettingsPanel/CenterContainer/VBoxContainer/DebugButton
@onready var close_settings = $SettingsPanel/CenterContainer/VBoxContainer/CloseSettings

var rebirth_cost = 100
var shake_intensity = 0.0

# --- EVENT SYSTEM VARIABLES ---
var event_timer: Timer
var active_event_node: Button = null
var event_panel: PanelContainer = null
var event_label: Label = null
var event_claim_button: Button = null
var current_event_reward = 0.0

func _ready():
	click_button.pressed.connect(_on_click_pressed)
	rebirth_button.pressed.connect(_on_rebirth_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	close_settings.pressed.connect(_on_close_settings_pressed)
	debug_button.pressed.connect(_on_debug_pressed)
	sfx_check.toggled.connect(_on_sfx_toggled)
	music_check.toggled.connect(_on_music_toggled)
	
	setup_event_system()
	
	# Dynamic Debug Event button inside Settings Panel
	var debug_event_btn = Button.new()
	debug_event_btn.text = "Debug : Déclencher Événement"
	debug_event_btn.custom_minimum_size = Vector2(0, 36)
	var debug_style = StyleBoxFlat.new()
	debug_style.bg_color = Color("#8338ec")
	debug_style.corner_radius_top_left = 8
	debug_style.corner_radius_top_right = 8
	debug_style.corner_radius_bottom_left = 8
	debug_style.corner_radius_bottom_right = 8
	debug_event_btn.add_theme_stylebox_override("normal", debug_style)
	debug_event_btn.pressed.connect(func():
		_on_close_settings_pressed()
		_on_event_timer_timeout()
	)
	$SettingsPanel/CenterContainer/VBoxContainer.add_child(debug_event_btn)
	$SettingsPanel/CenterContainer/VBoxContainer.move_child(debug_event_btn, $SettingsPanel/CenterContainer/VBoxContainer.get_child_count() - 2)
	
	# Dynamic Hard Reset button inside Settings Panel (Crimson Red Warning)
	var reset_btn = Button.new()
	reset_btn.text = "!!! EFFACER LA SAUVEGARDE !!!"
	reset_btn.custom_minimum_size = Vector2(0, 48)
	var reset_style = StyleBoxFlat.new()
	reset_style.bg_color = Color("#d90429") # Severe Crimson warning color
	reset_style.corner_radius_top_left = 12
	reset_style.corner_radius_top_right = 12
	reset_style.corner_radius_bottom_left = 12
	reset_style.corner_radius_bottom_right = 12
	reset_btn.add_theme_stylebox_override("normal", reset_style)
	
	var reset_style_hover = reset_style.duplicate()
	reset_style_hover.bg_color = Color("#ef233c")
	reset_btn.add_theme_stylebox_override("hover", reset_style_hover)
	
	reset_btn.pressed.connect(func():
		Global.play_sfx("crit")
		Global.hard_reset()
		get_tree().reload_current_scene()
	)
	$SettingsPanel/CenterContainer/VBoxContainer.add_child(reset_btn)
	$SettingsPanel/CenterContainer/VBoxContainer.move_child(reset_btn, $SettingsPanel/CenterContainer/VBoxContainer.get_child_count() - 2)
	
	# Load UI states
	sfx_check.button_pressed = Global.sfx_enabled
	music_check.button_pressed = Global.music_enabled
	
	# Design the main action buttons with the gorgeous premium prism-heart texture!
	var click_tex = load("res://assets/prism_heart.jpg")
	if click_tex:
		var click_style = StyleBoxTexture.new()
		click_style.texture = click_tex
		
		var click_hover = StyleBoxTexture.new()
		click_hover.texture = click_tex
		click_hover.modulate_color = Color(1.15, 1.15, 1.25, 1.0) # Radiant aura hover glow
		
		var click_pressed = StyleBoxTexture.new()
		click_pressed.texture = click_tex
		click_pressed.modulate_color = Color(0.8, 0.8, 0.9, 1.0) # Snappy feedback compression color
		
		click_button.add_theme_stylebox_override("normal", click_style)
		click_button.add_theme_stylebox_override("hover", click_hover)
		click_button.add_theme_stylebox_override("pressed", click_pressed)
		click_button.text = "" # Remove text to let the stunning art shine!
	else:
		var click_style = StyleBoxFlat.new()
		click_style.bg_color = Color("#4361ee")
		click_style.corner_radius_top_left = 20
		click_style.corner_radius_top_right = 20
		click_style.corner_radius_bottom_left = 20
		click_style.corner_radius_bottom_right = 20
		click_style.border_width_bottom = 8
		click_style.border_color = Color("#3a0ca3")
		click_button.add_theme_stylebox_override("normal", click_style)
		
		var click_hover = click_style.duplicate()
		click_hover.bg_color = Color("#4cc9f0")
		click_button.add_theme_stylebox_override("hover", click_hover)
		
		var click_pressed = click_style.duplicate()
		click_pressed.bg_color = Color("#3a0ca3")
		click_pressed.border_width_bottom = 0
		click_pressed.content_margin_top = 8
		click_button.add_theme_stylebox_override("pressed", click_pressed)
	
	var rebirth_style = StyleBoxFlat.new()
	rebirth_style.bg_color = Color("#00b4d8")
	rebirth_style.corner_radius_top_left = 20
	rebirth_style.corner_radius_top_right = 20
	rebirth_style.corner_radius_bottom_left = 20
	rebirth_style.corner_radius_bottom_right = 20
	rebirth_style.border_width_bottom = 8
	rebirth_style.border_color = Color("#0077b6")
	rebirth_button.add_theme_stylebox_override("normal", rebirth_style)
	
	var rebirth_hover = rebirth_style.duplicate()
	rebirth_hover.bg_color = Color("#90e0ef")
	rebirth_button.add_theme_stylebox_override("hover", rebirth_hover)
	
	var rebirth_pressed = rebirth_style.duplicate()
	rebirth_pressed.bg_color = Color("#0077b6")
	rebirth_pressed.border_width_bottom = 0
	rebirth_pressed.content_margin_top = 8
	rebirth_button.add_theme_stylebox_override("pressed", rebirth_pressed)
	
	var rebirth_disabled = rebirth_style.duplicate()
	rebirth_disabled.bg_color = Color("#112233")
	rebirth_disabled.border_color = Color("#0a1122")
	rebirth_button.add_theme_stylebox_override("disabled", rebirth_disabled)
	
	build_upgrades_ui()
	update_ui()
	setup_particles()
	
	# Update UI periodically (for idle generation)
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(update_ui)
	add_child(timer)

func _process(delta):
	if shake_intensity > 0.1:
		position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = lerp(shake_intensity, 0.0, 15.0 * delta)
	else:
		position = Vector2.ZERO

func setup_particles():
	var particles = CPUParticles2D.new()
	particles.position = Vector2(270, 960)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(270, 10)
	particles.direction = Vector2(0, -1)
	particles.spread = 15.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 25.0
	particles.initial_velocity_max = 75.0
	particles.amount = 25
	particles.lifetime = 12.0
	particles.preprocess = 6.0
	particles.color = Color("#4a1275") # Soft void purple
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0
	
	var color_ramp = Gradient.new()
	color_ramp.set_color(0, Color(0.6, 0.2, 0.9, 0.3)) # Glowing translucent purple
	color_ramp.set_color(1, Color(0.1, 0.0, 0.2, 0.0)) # Smooth fade to void
	particles.color_ramp = color_ramp
	
	add_child(particles)
	move_child(particles, 0) # Place in background

func _on_click_pressed():
	var click_data = Global.get_click_value()
	Global.add_essence(click_data["value"])
	update_ui()
	
	# Trigger shake on critical hit
	if click_data["critical"]:
		shake_intensity = 12.0
	
	# Spawn floating text
	spawn_floating_text(click_data["value"], click_data["critical"])
	
	# SFX Audio
	if click_data["critical"]:
		Global.play_sfx("crit")
	else:
		Global.play_sfx("click")

func spawn_floating_text(amount: float, is_critical: bool):
	var float_label = Label.new()
	float_label.text = "+" + str(floor(amount))
	
	if is_critical:
		float_label.text += " (Crit!)"
		float_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
		float_label.add_theme_font_size_override("font_size", 36)
	else:
		float_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		float_label.add_theme_font_size_override("font_size", 28)
		
	# Randomize start position a bit near the center/button
	var start_pos = click_button.global_position + click_button.size / 2.0
	start_pos.x += randf_range(-50, 50)
	start_pos.y += randf_range(-20, 20)
	
	float_label.position = start_pos
	add_child(float_label)
	
	var end_pos = start_pos + Vector2(randf_range(-30, 30), -100)
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(float_label, "position", end_pos, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(float_label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(float_label.queue_free)

func build_upgrades_ui():
	# Clear existing
	for child in upgrades_container.get_children():
		child.queue_free()
		
	for upgrade in Global.upgrades_data:
		# Check if unlocked
		if Global.death_level < upgrade["required_death_level"]:
			continue
			
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(0, 120)
		panel.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.mouse_filter = Control.MOUSE_FILTER_PASS
		panel.add_child(hbox)
		
		var label = RichTextLabel.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.bbcode_enabled = true
		label.scroll_active = false
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		hbox.add_child(label)
		
		var button = Button.new()
		button.text = "Acheter"
		button.custom_minimum_size = Vector2(100, 50)
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var u_id = upgrade["id"] # Store ID for lambda
		button.pressed.connect(func(): _on_upgrade_pressed(u_id))
		hbox.add_child(button)
		
		upgrades_container.add_child(panel)

func update_ui():
	stats_label.text = "Essence : " + str(floor(Global.essence)) + "\n" + \
					   "Niveau de Mort : " + str(Global.death_level) + " | Cycles : " + str(Global.cycles)
					   
	var required = 100 * pow(Global.death_level, 2)
	level_progress.max_value = required
	level_progress.value = Global.total_essence
	
	var current_life = Global.get_current_life()
					   
	# Update upgrades list
	var index = 0
	for upgrade in Global.upgrades_data:
		if Global.death_level < upgrade["required_death_level"]:
			continue
			
		if index >= upgrades_container.get_child_count():
			build_upgrades_ui() # Rebuild if new ones unlocked
			break
			
		var panel = upgrades_container.get_child(index)
		var hbox = panel.get_child(0)
		var label = hbox.get_child(0) as RichTextLabel
		var button = hbox.get_child(1) as Button
		
		var current_level = Global.purchased_upgrades.get(upgrade["id"], 0)
		var cost = upgrade["base_cost"] * pow(upgrade["cost_multiplier"], current_level)
		
		# Apply Richesse discount
		if current_life.has("richesse"):
			var discount = clamp(current_life["richesse"] / 500.0, 0.0, 0.8) # max 80% discount
			cost *= (1.0 - discount)
			
		# Apply Sagesse Millénaire (cost_reduction) discount
		var wisdom_level = Global.purchased_upgrades.get("cost_reduction", 0)
		if wisdom_level > 0:
			cost *= (1.0 - (wisdom_level * 0.05))
			
		cost = floor(cost)
		
		var icon = "[💎]"
		if upgrade["id"] == "click_power": icon = "[CLIC]"
		elif upgrade["id"] == "idle_generation": icon = "[AUTO]"
		elif upgrade["id"] == "starting_stats": icon = "[STATS]"
		elif upgrade["id"] == "click_frenzy": icon = "[FUREUR]"
		elif upgrade["id"] == "idle_multiplier": icon = "[PROD]"
		elif upgrade["id"] == "luck_boost": icon = "[CHANCE]"
		elif upgrade["id"] == "cost_reduction": icon = "[WISDOM]"
		elif upgrade["id"] == "ascension_prep": icon = "[AURA]"
		
		var text = "[color=#9d4edd][b]" + icon + " " + upgrade["name"] + "[/b][/color] (Nv " + str(current_level) + "/" + str(upgrade["max_level"]) + ")\n"
		text += "[color=#a0a0b0][font_size=16]" + upgrade["description"] + "[/font_size][/color]\n"
		text += "[color=#ffb703][b]Coût: " + str(cost) + " Essence[/b][/color]"
		label.text = text
		
		if current_level >= upgrade["max_level"]:
			button.text = "Max"
			button.disabled = true
		else:
			button.text = "Acheter"
			button.disabled = Global.essence < cost
			
		index += 1
		
	# Update rebirth button
	rebirth_cost = 300 * pow(1.8, Global.cycles)
	if current_life.has("beaute"):
		var discount = clamp(current_life["beaute"] / 500.0, 0.0, 0.8) # max 80% discount
		rebirth_cost *= (1.0 - discount)
		
	# Apply Aura Céleste (ascension_prep)
	var prep_level = Global.purchased_upgrades.get("ascension_prep", 0)
	if prep_level > 0:
		rebirth_cost *= (1.0 - (prep_level * 0.10))
		
	rebirth_cost = floor(rebirth_cost)
	
	# Compute total purchased upgrades for Ascension progression gate
	var total_upgrades = 0
	for up_id in Global.purchased_upgrades:
		total_upgrades += Global.purchased_upgrades[up_id]
		
	if Global.cycles >= 30:
		if total_upgrades >= 80 and prep_level >= 5:
			rebirth_button.text = "ASCENSION FINALE !"
			rebirth_button.disabled = false
			rebirth_button.add_theme_color_override("font_color", Color(1, 0.84, 0)) # Gold
		else:
			var req_txt = ""
			if total_upgrades < 80:
				req_txt += "80 Amél. (" + str(total_upgrades) + "/80) "
			if prep_level < 5:
				req_txt += "Aura Nv 5 (" + str(prep_level) + "/5)"
			rebirth_button.text = "[Bloqué] Ascension (Requis: " + req_txt + ")"
			rebirth_button.disabled = true
	else:
		var required_harvest = max(rebirth_cost * (0.8 + Global.cycles * 0.05), 300.0)
		if Global.cycle_essence_harvested < required_harvest:
			rebirth_button.text = "[Requis] Récolte: " + str(floor(Global.cycle_essence_harvested)) + "/" + str(floor(required_harvest)) + " Essence"
			rebirth_button.disabled = true
		else:
			rebirth_button.text = "Renaissance (Coût: " + str(floor(rebirth_cost)) + ")"
			rebirth_button.disabled = Global.essence < rebirth_cost

func _on_upgrade_pressed(upgrade_id: String):
	Global.purchase_upgrade(upgrade_id)
	update_ui()

func _on_rebirth_pressed():
	var total_upgrades = 0
	for up_id in Global.purchased_upgrades:
		total_upgrades += Global.purchased_upgrades[up_id]
	var prep_level = Global.purchased_upgrades.get("ascension_prep", 0)
		
	if Global.cycles >= 30:
		if total_upgrades >= 80 and prep_level >= 5:
			get_tree().change_scene_to_file("res://scenes/AscensionScene.tscn")
	elif Global.essence >= rebirth_cost:
		var required_harvest = max(rebirth_cost * (0.8 + Global.cycles * 0.05), 300.0)
		if Global.cycle_essence_harvested >= required_harvest:
			# Calculate Karmic Blessing before rebirthing
			var ratio = Global.cycle_essence_harvested / required_harvest
			if ratio >= 10.0:
				Global.karmic_bonus_stats = 50.0
				Global.karmic_essence_mult = 2.0 # Double essence for the next life!
				print("Reborn with GOLD KARMA (10x harvest requirement)!")
			elif ratio >= 5.0:
				Global.karmic_bonus_stats = 25.0
				Global.karmic_essence_mult = 1.5 # +50% essence for the next life!
				print("Reborn with SILVER KARMA (5x harvest requirement)!")
			elif ratio >= 3.0:
				Global.karmic_bonus_stats = 10.0
				Global.karmic_essence_mult = 1.25 # +25% essence for the next life!
				print("Reborn with BRONZE KARMA (3x harvest requirement)!")
			else:
				Global.karmic_bonus_stats = 0.0
				Global.karmic_essence_mult = 1.0
				
			Global.essence -= rebirth_cost
			Global.rebirth()
			get_tree().change_scene_to_file("res://scenes/LifeScene.tscn")

func _on_settings_pressed():
	settings_panel.visible = true

func _on_close_settings_pressed():
	settings_panel.visible = false

func _on_debug_pressed():
	Global.add_essence(1000)
	update_ui()

func _on_sfx_toggled(toggled_on: bool):
	Global.sfx_enabled = toggled_on
	Global.save_game()

func _on_music_toggled(toggled_on: bool):
	Global.music_enabled = toggled_on
	Global.save_game()

# --- DYNAMIC RANDOM EVENT SYSTEM ---
func setup_event_system():
	# Event trigger timer (ticks every 45s)
	event_timer = Timer.new()
	event_timer.wait_time = 45.0
	event_timer.autostart = true
	event_timer.timeout.connect(_on_event_timer_timeout)
	add_child(event_timer)
	
	# Event Panel (initially hidden offscreen at y=-250)
	event_panel = PanelContainer.new()
	event_panel.custom_minimum_size = Vector2(340, 160)
	event_panel.position = Vector2(19, -250) # Centered on a 378px wide viewport
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.15, 0.95) # Soft translucent dark void blue
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 4
	style.border_color = Color("#8338ec") # Radiant purple border
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 15
	style.content_margin_right = 15
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	event_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	
	var title = Label.new()
	title.text = "📜 Événement Mystique !"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	vbox.add_child(title)
	
	event_label = Label.new()
	event_label.text = ""
	event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	event_label.add_theme_font_size_override("font_size", 12)
	event_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	vbox.add_child(event_label)
	
	event_claim_button = Button.new()
	event_claim_button.text = "Accepter le Don"
	event_claim_button.custom_minimum_size = Vector2(0, 36)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("#8338ec")
	btn_style.corner_radius_top_left = 10
	btn_style.corner_radius_top_right = 10
	btn_style.corner_radius_bottom_left = 10
	btn_style.corner_radius_bottom_right = 10
	event_claim_button.add_theme_stylebox_override("normal", btn_style)
	
	var btn_style_pressed = btn_style.duplicate()
	btn_style_pressed.bg_color = Color("#3a0ca3")
	event_claim_button.add_theme_stylebox_override("pressed", btn_style_pressed)
	
	event_claim_button.pressed.connect(_on_claim_pressed)
	vbox.add_child(event_claim_button)
	
	event_panel.add_child(vbox)
	add_child(event_panel)

func _on_event_timer_timeout():
	if active_event_node != null or event_panel.position.y > 0:
		return
		
	# Spawn a floating magical scroll
	active_event_node = Button.new()
	active_event_node.text = "📜"
	active_event_node.add_theme_font_size_override("font_size", 30)
	active_event_node.flat = true
	active_event_node.position = Vector2(randf_range(40, 300), randf_range(160, 480))
	active_event_node.pressed.connect(_on_event_clicked)
	add_child(active_event_node)
	
	# Float animation
	var tween = create_tween().set_loops()
	tween.tween_property(active_event_node, "position:y", active_event_node.position.y - 12.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(active_event_node, "position:y", active_event_node.position.y, 1.0).set_trans(Tween.TRANS_SINE)
	
	# Expiration after 15 seconds if ignored
	get_tree().create_timer(15.0).timeout.connect(func():
		if is_instance_valid(active_event_node):
			active_event_node.queue_free()
			active_event_node = null
	)

func _on_event_clicked():
	if not is_instance_valid(active_event_node):
		return
		
	active_event_node.queue_free()
	active_event_node = null
	
	# Play chime sound
	Global.play_sfx("buy")
	
	# Calculate reward based on last life stats and death level
	var life = Global.get_current_life()
	var base_multiplier = 25.0 * Global.death_level
	current_event_reward = 120.0 * Global.death_level
	
	var event_desc = ""
	
	if life.size() > 0:
		var stats = ["richesse", "intelligence", "chance", "geographie", "beaute"]
		var max_stat = "richesse"
		var max_val = life.get("richesse", 0.0)
		for s in stats:
			if life.get(s, 0.0) > max_val:
				max_val = life.get(s, 0.0)
				max_stat = s
				
		current_event_reward = max_val * base_multiplier
		
		if max_val < 30.0:
			event_desc = "Souvenir Modeste : Un vieux compagnon de route a versé une larme et partagé son maigre repas en souvenir de votre bonté.\n\nEssence : +" + str(floor(current_event_reward))
		elif max_stat == "richesse":
			event_desc = "Héritage Céleste : Vos descendants ont découvert votre coffre-fort caché. Ils ont érigé un temple doré en votre mémoire !\n\nEssence : +" + str(floor(current_event_reward))
		elif max_stat == "intelligence":
			event_desc = "Redécouverte Scientifique : Vos formules physiques révolutionnaires ont été publiées à titre posthume par vos élèves !\n\nEssence : +" + str(floor(current_event_reward))
		elif max_stat == "chance":
			event_desc = "Alignement Cosmique : Votre chance insolente continue après la mort, attirant une comète pleine d'essence éthérique !\n\nEssence : +" + str(floor(current_event_reward))
		elif max_stat == "geographie":
			event_desc = "L'Or des Explorateurs : Vos anciens carnets d'expédition ont guidé des marins vers une nouvelle mine de diamants !\n\nEssence : +" + str(floor(current_event_reward))
		elif max_stat == "beaute":
			event_desc = "Mausolée Éternel : Vos fidèles admirateurs ont bâti un somptueux temple de marbre blanc dédié à votre splendeur !\n\nEssence : +" + str(floor(current_event_reward))
	else:
		event_desc = "Prière Pure : Une prière sincère d'un habitant de la Terre traverse le vide et vous remplit d'énergie spirituelle !\n\nEssence : +" + str(floor(current_event_reward))
		
	event_label.text = event_desc
	
	# Slide in Event Panel
	var tween = create_tween()
	tween.tween_property(event_panel, "position:y", 40.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_claim_pressed():
	Global.add_essence(current_event_reward)
	update_ui()
	
	Global.play_sfx("levelup")
	spawn_floating_text(current_event_reward, true)
	
	# Slide out Event Panel
	var tween = create_tween()
	tween.tween_property(event_panel, "position:y", -250.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
