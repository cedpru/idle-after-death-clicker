# AI Context & Project Hand-off Document

## 🎮 Project Overview
**Name**: Idle After Death Clicker
**Engine**: Godot 4.6.2 (GDScript)
**Target**: Mobile (Portrait 540x960)
**Concept**: A clicker/idle game where the player harvests "Essence" in the afterlife (Death), buys upgrades, and undergoes "Rebirth" (Life) to generate passive stats. After 10 lives, the player performs an "Ascension" to gain permanent multipliers based on their total score.

## 🏗️ Architecture & Scenes
1. **`scenes/Game.tscn`**: The absolute root entry point. It simply redirects to `DeathScene.tscn` using `call_deferred` to avoid scene tree conflicts on startup.
2. **`scenes/DeathScene.tscn`** (`DeathScene.gd`): The main hub. Contains the clicker button, the idle generation loop, the progression bar for "Death Level", and the dynamically loaded list of upgrades. Also contains the Settings/Debug panel.
3. **`scenes/LifeScene.tscn`** (`LifeScene.gd`): The rebirth screen. Displays the randomly generated stats of the current life, an animated emoji avatar based on the dominant stat, and a randomized flavor text describing the life. Uses dynamic backgrounds.
4. **`scenes/AscensionScene.tscn`** (`AscensionScene.gd`): The final screen reached after 10 lives and 15 upgrades. Calculates the average stats of all 10 lives, triggers one of 6 unique narrative endings, and shows a nostalgic scrollable recap of all lives lived.
5. **`scripts/Global.gd`** (Autoload): The heart of the game. Manages all variables (`essence`, `death_level`, `cycles`, `lives`, `purchased_upgrades`), the autosave timer (30s), the idle timer (1s), and applies upgrade effects dynamically. It also dynamically injects a custom Theme (`setup_theme()`) to all UI nodes.

## 💾 Data & Persistence
- **Save File**: Saved locally at `user://savegame.json`. 
- **Upgrades Database**: Loaded from `res://data/death_upgrades.json`. It contains 8 upgrades (click power, idle multiplier, cost reduction, stat boosts, etc.).

## 🎨 Design System
- **Theme**: A procedural "Dark Glassmorphism" theme is generated inside `Global.gd` -> `setup_theme()`. It overrides `StyleBoxFlat` for buttons (rounded, thick bottom borders for 3D effect) and panels.
- **Animations**: Godot 4 `Tweens` are heavily used (e.g., `LifeScene.gd`) to animate text fade-ins, scales, and bouncing effects. Emojis are used as lightweight assets for avatars and upgrade icons.
- **Resolution**: Base resolution is 540x960. All UI elements use anchors and `MarginContainers`/`VBoxContainers` to scale cleanly.

## ⚙️ Mechanics Details
- **Stats Impact**: The stats generated upon rebirth (Richesse, Intelligence, Chance, Géographie, Beauté) have immediate gameplay effects calculated in `DeathScene.gd` and `Global.gd`:
  - *Richesse*: Up to 80% discount on upgrade costs.
  - *Beauté*: Up to 80% discount on Rebirth cost.
  - *Intelligence*: Multiplies idle essence generation.
  - *Géographie*: Multiplies base click value.
  - *Chance*: 50% chance at 100 Luck to trigger a critical click (x5 essence).
- **Anti-Speedrun Progression Gate**: Ascension is locked until you have completed **10 lives** AND purchased **at least 15 cumulative upgrade levels** from Death.

## 🚀 Current Status & Next Steps (TODO)
- **Status**: The core loop and all 6 polish milestones on the Roadmap are **100% complete** and fully operational!
- **Roadmap**: See [ROADMAP.md](./ROADMAP.md) for the detailed step-by-step dopamine/juiciness polish plan and professional graphic suggestions.
