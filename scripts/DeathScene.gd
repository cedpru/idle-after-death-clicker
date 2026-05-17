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

func _ready():
	click_button.pressed.connect(_on_click_pressed)
	rebirth_button.pressed.connect(_on_rebirth_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	close_settings.pressed.connect(_on_close_settings_pressed)
	debug_button.pressed.connect(_on_debug_pressed)
	sfx_check.toggled.connect(_on_sfx_toggled)
	music_check.toggled.connect(_on_music_toggled)
	
	# Load UI states
	sfx_check.button_pressed = Global.sfx_enabled
	music_check.button_pressed = Global.music_enabled
	
	# Design the main action buttons
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
	
	var rebirth_style = click_style.duplicate()
	rebirth_style.bg_color = Color("#00b4d8")
	rebirth_style.border_color = Color("#0077b6")
	rebirth_button.add_theme_stylebox_override("normal", rebirth_style)
	
	var rebirth_hover = click_hover.duplicate()
	rebirth_hover.bg_color = Color("#90e0ef")
	rebirth_button.add_theme_stylebox_override("hover", rebirth_hover)
	
	var rebirth_pressed = click_pressed.duplicate()
	rebirth_pressed.bg_color = Color("#0077b6")
	rebirth_button.add_theme_stylebox_override("pressed", rebirth_pressed)
	
	var rebirth_disabled = rebirth_style.duplicate()
	rebirth_disabled.bg_color = Color("#112233")
	rebirth_disabled.border_color = Color("#0a1122")
	rebirth_button.add_theme_stylebox_override("disabled", rebirth_disabled)
	
	build_upgrades_ui()
	update_ui()
	
	# Update UI periodically (for idle generation)
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(update_ui)
	add_child(timer)

func _on_click_pressed():
	Global.add_essence(Global.get_click_value())
	update_ui()

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
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		panel.add_child(hbox)
		
		var label = RichTextLabel.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.bbcode_enabled = true
		label.scroll_active = false
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
		
		var icon = "💎"
		if upgrade["id"] == "click_power": icon = "🖱️"
		elif upgrade["id"] == "idle_generation": icon = "⏳"
		elif upgrade["id"] == "starting_stats": icon = "✨"
		elif upgrade["id"] == "click_frenzy": icon = "🔥"
		elif upgrade["id"] == "idle_multiplier": icon = "🌀"
		elif upgrade["id"] == "luck_boost": icon = "🎲"
		elif upgrade["id"] == "cost_reduction": icon = "📜"
		elif upgrade["id"] == "ascension_prep": icon = "👑"
		
		var text = "[color=#9d4edd][b]" + icon + " " + upgrade["name"] + "[/b][/color] (Nv " + str(current_level) + "/" + str(upgrade["max_level"]) + ")\n"
		text += "[color=#a0a0b0][font_size=16]" + upgrade["description"] + "[/font_size][/color]\n"
		text += "[color=#ffb703][b]Coût: " + str(cost) + " 💀[/b][/color]"
		label.text = text
		
		if current_level >= upgrade["max_level"]:
			button.text = "Max"
			button.disabled = true
		else:
			button.text = "Acheter"
			button.disabled = Global.essence < cost
			
		index += 1
		
	# Update rebirth button
	rebirth_cost = 100 * pow(1.5, Global.cycles)
	if current_life.has("beaute"):
		var discount = clamp(current_life["beaute"] / 500.0, 0.0, 0.8) # max 80% discount
		rebirth_cost *= (1.0 - discount)
		
	# Apply Aura Céleste (ascension_prep)
	var prep_level = Global.purchased_upgrades.get("ascension_prep", 0)
	if prep_level > 0:
		rebirth_cost *= (1.0 - (prep_level * 0.10))
		
	rebirth_cost = floor(rebirth_cost)
	
	if Global.cycles >= 10:
		rebirth_button.text = "Ascension Finale !"
		rebirth_button.disabled = false
		rebirth_button.add_theme_color_override("font_color", Color(1, 0.84, 0)) # Gold
	else:
		rebirth_button.text = "Renaissance (Coût: " + str(floor(rebirth_cost)) + ")"
		rebirth_button.disabled = Global.essence < rebirth_cost

func _on_upgrade_pressed(upgrade_id: String):
	Global.purchase_upgrade(upgrade_id)
	update_ui()

func _on_rebirth_pressed():
	if Global.cycles >= 10:
		get_tree().change_scene_to_file("res://scenes/AscensionScene.tscn")
	elif Global.essence >= rebirth_cost:
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
