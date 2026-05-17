extends Control

signal upgrade_purchased(upgrade_type: String, cost: int)

var upgrade_costs = {
	"click_power": 10,
	"auto_clicker": 50
}

var upgrade_levels = {
	"click_power": 1,
	"auto_clicker": 0
}

@onready var click_power_button = $Panel/VBoxContainer/ClickPowerUpgrade
@onready var auto_clicker_button = $Panel/VBoxContainer/AutoClickerUpgrade
@onready var close_button = $Panel/VBoxContainer/CloseButton

func _ready():
	click_power_button.pressed.connect(_on_click_power_pressed)
	auto_clicker_button.pressed.connect(_on_auto_clicker_pressed)
	close_button.pressed.connect(_on_close_pressed)
	update_buttons()

func update_buttons():
	click_power_button.text = "Click Power (Cost: %d) - Level %d" % [upgrade_costs["click_power"], upgrade_levels["click_power"]]
	auto_clicker_button.text = "Auto Clicker (Cost: %d) - Level %d" % [upgrade_costs["auto_clicker"], upgrade_levels["auto_clicker"]]

func _on_click_power_pressed():
	upgrade_purchased.emit("click_power", upgrade_costs["click_power"])
	upgrade_levels["click_power"] += 1
	upgrade_costs["click_power"] = int(upgrade_costs["click_power"] * 1.5)
	update_buttons()

func _on_auto_clicker_pressed():
	upgrade_purchased.emit("auto_clicker", upgrade_costs["auto_clicker"])
	upgrade_levels["auto_clicker"] += 1
	upgrade_costs["auto_clicker"] = int(upgrade_costs["auto_clicker"] * 1.3)
	update_buttons()

func _on_close_pressed():
	queue_free()
