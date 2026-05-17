extends Control

var coins: int = 0
var clicks: int = 0
var coins_per_click: int = 1
var coins_per_second: float = 0.0

var upgrade_costs = {
	"click_power": 10,
	"auto_clicker": 50
}

var upgrade_levels = {
	"click_power": 1,
	"auto_clicker": 0
}

@onready var currency_label = $VBoxContainer/CurrencyLabel
@onready var clicks_label = $VBoxContainer/ClicksLabel
@onready var click_button = $VBoxContainer/ClickButton
@onready var per_second_label = $VBoxContainer/PerSecondLabel
@onready var upgrades_button = $VBoxContainer/UpgradesButton

func _ready():
	click_button.pressed.connect(_on_click_button_pressed)
	upgrades_button.pressed.connect(_on_upgrades_button_pressed)
	load_game()
	update_ui()

func _process(delta):
	if coins_per_second > 0:
		coins += int(coins_per_second * delta)
		update_ui()

func _on_click_button_pressed():
	coins += coins_per_click
	clicks += 1
	update_ui()
	save_game()

func _on_upgrades_button_pressed():
	show_upgrades_menu()

func update_ui():
	currency_label.text = "Coins: %d" % coins
	clicks_label.text = "Clicks: %d" % clicks
	per_second_label.text = "Per Second: %.1f" % coins_per_second

func show_upgrades_menu():
	var upgrades_scene = load("res://scenes/Upgrades.tscn").instantiate()
	add_child(upgrades_scene)
	upgrades_scene.upgrade_purchased.connect(_on_upgrade_purchased)

func _on_upgrade_purchased(upgrade_type: String, cost: int):
	if coins >= cost:
		coins -= cost
		apply_upgrade(upgrade_type)
		save_game()
		update_ui()

func apply_upgrade(upgrade_type: String):
	match upgrade_type:
		"click_power":
			upgrade_levels["click_power"] += 1
			coins_per_click = upgrade_levels["click_power"]
			upgrade_costs["click_power"] = int(upgrade_costs["click_power"] * 1.5)
		"auto_clicker":
			upgrade_levels["auto_clicker"] += 1
			coins_per_second += 1.0
			upgrade_costs["auto_clicker"] = int(upgrade_costs["auto_clicker"] * 1.3)

func save_game():
	var save_data = {
		"coins": coins,
		"clicks": clicks,
		"coins_per_click": coins_per_click,
		"coins_per_second": coins_per_second,
		"upgrade_costs": upgrade_costs,
		"upgrade_levels": upgrade_levels
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game():
	if not FileAccess.file_exists("user://savegame.json"):
		return
	
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result == OK:
		var save_data = json.data
		coins = save_data.get("coins", 0)
		clicks = save_data.get("clicks", 0)
		coins_per_click = save_data.get("coins_per_click", 1)
		coins_per_second = save_data.get("coins_per_second", 0.0)
		upgrade_costs = save_data.get("upgrade_costs", upgrade_costs)
		upgrade_levels = save_data.get("upgrade_levels", upgrade_levels)
