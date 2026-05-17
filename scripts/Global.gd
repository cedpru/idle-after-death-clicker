extends Node

var essence: float = 0.0
var total_essence: float = 0.0
var click_multiplier: float = 1.0
var idle_generation: float = 0.0 # Essence per second

var death_level: int = 1
var cycles: int = 0
var lives: Array = []

var upgrades_data: Array = []
var purchased_upgrades: Dictionary = {} # e.g. {"upgrade_id": level}

var save_path = "user://savegame.json"

var idle_timer: Timer
var autosave_timer: Timer

func _ready():
	setup_theme()
	load_upgrades()
	load_game()

func setup_theme():
	var theme = Theme.new()
	
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("#2a2b38")
	btn_normal.corner_radius_top_left = 16
	btn_normal.corner_radius_top_right = 16
	btn_normal.corner_radius_bottom_left = 16
	btn_normal.corner_radius_bottom_right = 16
	btn_normal.border_width_bottom = 6
	btn_normal.border_color = Color("#171821")
	btn_normal.content_margin_left = 15
	btn_normal.content_margin_right = 15
	btn_normal.content_margin_top = 10
	btn_normal.content_margin_bottom = 10
	theme.set_stylebox("normal", "Button", btn_normal)
	
	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color("#3e4053")
	theme.set_stylebox("hover", "Button", btn_hover)
	
	var btn_pressed = btn_normal.duplicate()
	btn_pressed.bg_color = Color("#171821")
	btn_pressed.border_width_bottom = 0
	btn_pressed.content_margin_top = 16
	btn_pressed.content_margin_bottom = 4
	theme.set_stylebox("pressed", "Button", btn_pressed)
	
	var btn_disabled = btn_normal.duplicate()
	btn_disabled.bg_color = Color("#1b1c24")
	btn_disabled.border_color = Color("#101116")
	theme.set_color("font_disabled_color", "Button", Color("#555555"))
	theme.set_stylebox("disabled", "Button", btn_disabled)
	
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = Color("#171821")
	progress_bg.corner_radius_top_left = 10
	progress_bg.corner_radius_top_right = 10
	progress_bg.corner_radius_bottom_left = 10
	progress_bg.corner_radius_bottom_right = 10
	theme.set_stylebox("background", "ProgressBar", progress_bg)
	
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = Color("#9d4edd")
	progress_fill.corner_radius_top_left = 10
	progress_fill.corner_radius_top_right = 10
	progress_fill.corner_radius_bottom_left = 10
	progress_fill.corner_radius_bottom_right = 10
	theme.set_stylebox("fill", "ProgressBar", progress_fill)
	
	var panel = StyleBoxFlat.new()
	panel.bg_color = Color("#1d1e26")
	panel.corner_radius_top_left = 12
	panel.corner_radius_top_right = 12
	panel.corner_radius_bottom_left = 12
	panel.border_width_left = 2
	panel.border_width_right = 2
	panel.border_width_top = 2
	panel.border_width_bottom = 2
	panel.border_color = Color("#343644")
	panel.content_margin_left = 15
	panel.content_margin_right = 15
	panel.content_margin_top = 15
	panel.content_margin_bottom = 15
	theme.set_stylebox("panel", "PanelContainer", panel)
	
	get_tree().root.theme = theme
	
	idle_timer = Timer.new()
	idle_timer.wait_time = 1.0
	idle_timer.autostart = true
	idle_timer.timeout.connect(_on_idle_timer_timeout)
	add_child(idle_timer)
	
	autosave_timer = Timer.new()
	autosave_timer.wait_time = 30.0
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(save_game)
	add_child(autosave_timer)
	
	music_timer = Timer.new()
	music_timer.wait_time = 1.5
	music_timer.autostart = true
	music_timer.timeout.connect(_on_music_timer_timeout)
	add_child(music_timer)

func get_current_life() -> Dictionary:
	if lives.size() > 0:
		return lives[-1]
	return {}

func _on_idle_timer_timeout():
	if idle_generation > 0:
		var amount = idle_generation
		var life = get_current_life()
		if life.has("intelligence"):
			amount *= (1.0 + life["intelligence"] / 100.0)
		add_essence(amount)

func get_click_value() -> Dictionary:
	var base_val = 1.0 * click_multiplier
	var life = get_current_life()
	var is_crit = false
	
	if life.has("geographie"):
		base_val *= (1.0 + life["geographie"] / 100.0)
		
	if life.has("chance"):
		if randf() < (life["chance"] / 100.0) * 0.5: # 50% chance at 100 Luck
			base_val *= 5.0 # Critical Hit
			is_crit = true
			
	return {"value": base_val, "critical": is_crit}

func add_essence(amount: float):
	essence += amount
	total_essence += amount
	check_death_level()

func check_death_level():
	# Simple progression: level up every 100 * level^2 total essence
	var required = 100 * pow(death_level, 2)
	if total_essence >= required:
		death_level += 1
		play_sfx("levelup")
		print("Death Level Up! Now level ", death_level)

func generate_life() -> Dictionary:
	var base_bonus = 0.0
	if purchased_upgrades.has("starting_stats"):
		base_bonus = purchased_upgrades["starting_stats"] * 5.0
		
	var luck_bonus = 0.0
	if purchased_upgrades.has("luck_boost"):
		luck_bonus = purchased_upgrades["luck_boost"] * 20.0
		
	# Select a dominant stat category to specialize the character
	var stats = ["richesse", "intelligence", "chance", "geographie", "beaute"]
	var dominant = stats[randi() % stats.size()]
	
	var life = {
		"richesse": randf_range(5.0, 45.0) + base_bonus,
		"intelligence": randf_range(5.0, 45.0) + base_bonus,
		"chance": randf_range(5.0, 45.0) + base_bonus + luck_bonus,
		"geographie": randf_range(5.0, 45.0) + base_bonus,
		"beaute": randf_range(5.0, 45.0) + base_bonus
	}
	
	# Give the dominant stat a powerful specialized boost
	life[dominant] += randf_range(45.0, 75.0)
	
	lives.append(life)
	return life

func rebirth():
	cycles += 1
	generate_life()
	save_game()

func load_upgrades():
	var file = FileAccess.open("res://data/death_upgrades.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			upgrades_data = json.data
		file.close()

func purchase_upgrade(upgrade_id: String):
	var upgrade_info = null
	for u in upgrades_data:
		if u["id"] == upgrade_id:
			upgrade_info = u
			break
			
	if upgrade_info == null:
		return
		
	var current_level = purchased_upgrades.get(upgrade_id, 0)
	if current_level >= upgrade_info["max_level"]:
		return
		
	var cost = upgrade_info["base_cost"] * pow(upgrade_info["cost_multiplier"], current_level)
	if essence >= cost:
		essence -= cost
		purchased_upgrades[upgrade_id] = current_level + 1
		apply_upgrade_effect(upgrade_id)
		play_sfx("buy")
		save_game()

var sfx_enabled: bool = true
var music_enabled: bool = true

func apply_upgrade_effect(upgrade_id: String):
	if upgrade_id == "click_power":
		click_multiplier *= 1.2
	elif upgrade_id == "idle_generation":
		idle_generation += 1.0
	elif upgrade_id == "click_frenzy":
		click_multiplier *= 2.0
	elif upgrade_id == "idle_multiplier":
		idle_generation *= 1.2
	# Others are handled dynamically

func save_game():
	var save_dict = {
		"essence": essence,
		"total_essence": total_essence,
		"click_multiplier": click_multiplier,
		"idle_generation": idle_generation,
		"death_level": death_level,
		"cycles": cycles,
		"lives": lives,
		"purchased_upgrades": purchased_upgrades,
		"ascension_multiplier": ascension_multiplier,
		"sfx_enabled": sfx_enabled,
		"music_enabled": music_enabled
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(save_dict))
		file.close()

func load_game():
	if not FileAccess.file_exists(save_path):
		return
		
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var data = json.data
			essence = data.get("essence", 0.0)
			total_essence = data.get("total_essence", 0.0)
			click_multiplier = data.get("click_multiplier", 1.0)
			idle_generation = data.get("idle_generation", 0.0)
			death_level = data.get("death_level", 1)
			cycles = data.get("cycles", 0)
			lives = data.get("lives", [])
			purchased_upgrades = data.get("purchased_upgrades", {})
			ascension_multiplier = data.get("ascension_multiplier", 1.0)
			sfx_enabled = data.get("sfx_enabled", true)
			music_enabled = data.get("music_enabled", true)
		file.close()

var ascension_multiplier: float = 1.0

func reset_for_ascension():
	essence = 0.0
	total_essence = 0.0
	click_multiplier = 1.0 * ascension_multiplier
	idle_generation = 0.0
	death_level = 1
	cycles = 0
	lives.clear()
	purchased_upgrades.clear()
	save_game()

# --- AUDIO SYSTEM (PROCEDURAL RETRO SYNTH & MUSIC) ---
var music_timer: Timer
var current_ambient_freq: float = 220.0
var music_notes = [220.0, 246.94, 261.63, 293.66, 329.63, 392.00, 440.00] # A minor / C major pentatonic scale notes

func _on_music_timer_timeout():
	if not music_enabled:
		return
	# 30% chance to play a soft, random chord tone in the background
	if randf() < 0.4:
		current_ambient_freq = music_notes[randi() % music_notes.size()]
		play_sfx("music_note")

func play_sfx(type: String):
	if type == "music_note" and not music_enabled:
		return
	if type != "music_note" and not sfx_enabled:
		return
		
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.finished.connect(player.queue_free)
	
	var stream = _generate_sfx_stream(type)
	if stream:
		player.stream = stream
		player.play()

func _generate_sfx_stream(type: String) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	wav.stereo = false
	
	var duration = 0.12
	if type == "buy": duration = 0.25
	elif type == "levelup": duration = 0.5
	elif type == "music_note": duration = 1.2
	
	var num_samples = int(22050 * duration)
	var bytes = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	var phase = 0.0
	for i in range(num_samples):
		var t = float(i) / num_samples
		var freq = 440.0
		
		if type == "click":
			freq = 700.0 - (300.0 * t) # Quick frequency slide down
		elif type == "crit":
			freq = 600.0 + (800.0 * t) # Higher slide up
		elif type == "buy":
			if t < 0.5:
				freq = 523.25 # C5
			else:
				freq = 659.25 # E5
		elif type == "levelup":
			if t < 0.25: freq = 261.63 # C4
			elif t < 0.5: freq = 329.63 # E4
			elif t < 0.75: freq = 392.00 # G4
			else: freq = 523.25 # C5
		elif type == "music_note":
			freq = current_ambient_freq
			
		phase += 2.0 * PI * freq / 22050.0
		var sample = int(sin(phase) * 8000.0) # Medium soft amplitude
		
		# Envelope fade/decay
		var env = 1.0 - t
		if type == "music_note":
			# Slow warm fade-in and soft decay for ambient background notes
			env = sin(t * PI) * 0.08 # Max 8% amplitude to make it very quiet and soft
		sample = int(sample * env)
		
		bytes.encode_s16(i * 2, sample)
		
	wav.data = bytes
	return wav
