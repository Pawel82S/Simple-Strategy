#class_name
extends Control
"""
Script description
"""
################################################################# SIGNALS ################################################################
################################################################# ENUMS ##################################################################
enum Difficulty {
	VERY_EASY,
	EASY,
	NORMAL,
	HARD,
	VERY_HARD,
	CRAZY,
	BYE,	# This is "I'm feeling lucky!" but much shorter to type
}

enum MapSize {
	VERY_SMALL,	# 4 players
	SMALL,		# 6 players
	NORMAL,		# 8 players
	LARGE,		# 12 players
	VERY_LARGE,	# 16 players
	ENORMOUS,	# 20 players
	GALAXY,		# 30 players
	CUSTOM,
}

enum PlayersCount {
	MIN = 2,
	MAX = 50,
}

enum PlantetCount {
	MIN = 5,
	MAX = 20,
}

enum GalaxySize {
	MIN = 11,
	MAX = 100,
}

enum ConnectionsPerSystem {
	MIN = 1,
	MAX = 4,
}

################################################################# CONSTANTS ##############################################################
const BONUS_MULTIPLAYER := 0.15
const SPACE_PER_PLANET := 9
const RACE_SLIDER_VALUES := [-3, -2.5, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3]
const MIN_SYSTEM_SEPARATION := 1
const MAX_CONNECTION_RANGE := 3

################################################################# EXPORT VAR #############################################################
################################################################# PUBLIC VAR #############################################################
################################################################# PRIVATE VAR ############################################################
var _difficulty: int = Difficulty.NORMAL
var _map_size: int = MapSize.VERY_SMALL
var _ai_ballance := 0.0
var _galaxy_map := GalaxyGenerator.new()
var _min_x := 0
var _max_x := 0
var _min_y := 0
var _max_y := 0

################################################################# ONREADY VAR ############################################################
# Race settings
onready var race_name_edit := $VBoxContainer/CategoriesContainer/RaceSettings/RaceNameContainer/NameEdit
onready var research_slider := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/ResearchValues/ResearchSlider
onready var research_val_lab := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/ResearchValues/ResearchValueLabel
onready var research_bonus_lab := $VBoxContainer/CategoriesContainer/RaceSettings/RaceDescriptionContainer/DescriptionValues/ResearchBonusLabel
onready var production_slider := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/ProductionValues/ProductionSlider
onready var production_val_lab := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/ProductionValues/ProductionValueLabel
onready var production_bonus_lab := $VBoxContainer/CategoriesContainer/RaceSettings/RaceDescriptionContainer/DescriptionValues/ProductionBonusLabel
onready var culture_slider := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/CultureValues/CultureSlider
onready var culture_val_lab := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/CultureValues/CultureValueLabel
onready var culture_bonus_lab := $VBoxContainer/CategoriesContainer/RaceSettings/RaceDescriptionContainer/DescriptionValues/CultureBonusLabel
onready var growth_slider := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/GrowthValues/GrowthSlider
onready var growth_val_lab := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/GrowthValues/GrowthValueLabel
onready var growth_bonus_lab := $VBoxContainer/CategoriesContainer/RaceSettings/RaceDescriptionContainer/DescriptionValues/GrowthBonusLabel
onready var wealth_slider := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/WealthValues/WealthSlider
onready var wealth_val_lab := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/WealthValues/WealthValueLabel
onready var wealth_bonus_lab := $VBoxContainer/CategoriesContainer/RaceSettings/RaceDescriptionContainer/DescriptionValues/WealthBonusLabel
onready var ships_slider := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/ShipsValues/ShipsSlider
onready var ships_val_lab := $VBoxContainer/CategoriesContainer/RaceSettings/LabelsAndValues/Values/ShipsValues/ShipsValueLabel
onready var ships_bonus_lab := $VBoxContainer/CategoriesContainer/RaceSettings/RaceDescriptionContainer/DescriptionValues/ShipsBonusLabel
onready var race_balance_value := $VBoxContainer/CategoriesContainer/RaceSettings/RaceBalanceContainer/BalanceValueLabel
onready var ai_descr_label := $VBoxContainer/CategoriesContainer/RaceSettings/AISettingsContainer/AIDescriptionLabel

# Galaxy settings
onready var galaxy_descr := $VBoxContainer/CategoriesContainer/GameSettings/GalaxySizeContainer/GalaxyDesciptionLabel
onready var players_slider := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/PlayerValues/PlayersSlider
onready var players_val_lab := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/PlayerValues/PlayersValueLabel
onready var systems_slider := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/SystemValues/SystemSlider
onready var systems_val_lab := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/SystemValues/SystemValueLabel
onready var width_slider := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/WidthValues/WidthSlider
onready var width_val_lab := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/WidthValues/WidthValueLabel
onready var height_slider := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/HeightValues/HeightSlider
onready var height_val_lab := $VBoxContainer/CategoriesContainer/GameSettings/LabelsAndValues/Values/HeightValues/HeightValueLabel
onready var galaxy_preview := $VBoxContainer/CategoriesContainer/GameSettings/GalaxyPreviewContainer
onready var minimap := $VBoxContainer/CategoriesContainer/GameSettings/GalaxyPreviewContainer/MiniMap

# Main buttons
onready var start_button := $VBoxContainer/ButtonsContainer/StartButton

################################################################# SETTERS & GETTERS ######################################################
################################################################# BUILT-IN METHODS #######################################################
func _ready() -> void:
	_default_settings()
	_calculate_x_range()
	_calculate_y_range()


################################################################# PUBLIC METHODS #########################################################
################################################################# PRIVATE METHODS ########################################################
func _default_settings() -> void:
	galaxy_descr.text = "This galaxy size is perfect for beginners and short games. You will be playing with 3 AI."
	players_slider.value = 4
	systems_slider.value = 7
	_galaxy_map.players_count = 4
	_galaxy_map.systems_per_player = 7
	_galaxy_map.width = 17
	_galaxy_map.height = 17
	_calculate_galaxy_size()
	_set_map_size_to_min()


func _calculate_x_range() -> void:
	_min_x = width_slider.value / 2
	_max_x = width_slider.value - _min_x - 1


func _calculate_y_range() -> void:
	_min_y = height_slider.value / 2
	_max_y = height_slider.value - _min_y - 1


func _on_BackButton_pressed() -> void:
	Func.ignore_result(get_tree().change_scene("res://src/GUI/MainMenu.tscn"))


func _on_StartButton_pressed() -> void:
	Data.system_positions = _galaxy_map.system_positions
	Data.system_path = _galaxy_map.system_path
	_generate_ai()
	_place_players()
	Func.ignore_result(get_tree().change_scene("res://src/Game/Game.tscn"))


func _generate_ai() -> void:
	for _a in range(players_slider.value - 1):
		pass


func _place_players() -> void:
	pass


func _on_ResearchSlider_value_changed(value: float) -> void:
	research_val_lab.text = str(value)
	var balance := _calculate_race_balance()
	race_balance_value.text = str(balance)
	research_bonus_lab.text = "%.1f%%" % (100 + BONUS_MULTIPLAYER * value * 100)
	_on_NameEdit_text_changed(race_name_edit.text)


func _on_ProductionSlider_value_changed(value: float) -> void:
	production_val_lab.text = str(value)
	var balance := _calculate_race_balance()
	race_balance_value.text = str(balance)
	production_bonus_lab.text = "%.1f%%" % (100 + BONUS_MULTIPLAYER * value * 100)
	_on_NameEdit_text_changed(race_name_edit.text)


func _on_CultureSlider_value_changed(value: float) -> void:
	culture_val_lab.text = str(value)
	var balance := _calculate_race_balance()
	race_balance_value.text = str(balance)
	culture_bonus_lab.text = "%.1f%%" % (100 + BONUS_MULTIPLAYER * value * 100)
	_on_NameEdit_text_changed(race_name_edit.text)


func _on_GrowthSlider_value_changed(value: float) -> void:
	growth_val_lab.text = str(value)
	var balance := _calculate_race_balance()
	race_balance_value.text = str(balance)
	growth_bonus_lab.text = "%.1f%%" % (100 + BONUS_MULTIPLAYER * value * 100)
	_on_NameEdit_text_changed(race_name_edit.text)


func _on_WealthSlider_value_changed(value: float) -> void:
	wealth_val_lab.text = str(value)
	var balance := _calculate_race_balance()
	race_balance_value.text = str(balance)
	wealth_bonus_lab.text = "%.1f%%" % (100 + BONUS_MULTIPLAYER * value * 100)
	_on_NameEdit_text_changed(race_name_edit.text)


func _on_ShipsSlider_value_changed(value: float) -> void:
	ships_val_lab.text = str(value)
	var balance := _calculate_race_balance()
	race_balance_value.text = str(balance)
	ships_bonus_lab.text = "%.1f%%" % (100 + BONUS_MULTIPLAYER * value * 100)
	_on_NameEdit_text_changed(race_name_edit.text)


func _calculate_race_balance() -> int:
	var research = research_slider.value
	var production = production_slider.value
	var culture = culture_slider.value
	var growth = growth_slider.value
	var wealth = wealth_slider.value
	var ships = ships_slider.value
	var total = research + production + culture + growth + wealth + ships
	return total


func _on_NameEdit_text_changed(new_text: String) -> void:
	if !new_text.strip_edges().empty() && _calculate_race_balance() == 0:
		start_button.disabled = false
	else:
		start_button.disabled = true


func _on_AiDifficultyButton_item_selected(index: int) -> void:
	match index:
		Difficulty.VERY_EASY:
			ai_descr_label.text = "AI have 2 points less to spend when creating race (balance = -2)."
			_ai_ballance = -2
		
		Difficulty.EASY:
			ai_descr_label.text = "AI have 1 points less to spend when creating race (balance = -1)."
			_ai_ballance = -1
		
		Difficulty.NORMAL:
			ai_descr_label.text = "AI does not have any advantages over player (balance = 0)."
			_ai_ballance = 0
		
		Difficulty.HARD:
			ai_descr_label.text = "AI have 1.5 points more to spend when creating race (balance = 1.5)."
			_ai_ballance = 1.5
		
		Difficulty.VERY_HARD:
			ai_descr_label.text = "AI have 3 points more to spend when creating race (balance = 3)."
			_ai_ballance = 3
		
		Difficulty.CRAZY:
			ai_descr_label.text = "AI have 7 points more to spend when creating race (balance = 7)."
			_ai_ballance = 7
		
		Difficulty.BYE:	# I'm feeling lucky!
			ai_descr_label.text = "AI have all stats at maximum level (balance = 18)."
			_ai_ballance = 18
		
		_: assert(false, "Unknown difficulty")
	
	_difficulty = index


func _on_SizeOptionButton_item_selected(index: int) -> void:
	_enable_galaxy_settings(false)
	players_slider.min_value = PlayersCount.MIN
	players_slider.max_value = PlayersCount.MAX
	systems_slider.min_value = PlantetCount.MIN
	systems_slider.max_value = PlantetCount.MAX
	width_slider.min_value = GalaxySize.MIN
	width_slider.max_value = GalaxySize.MAX
	height_slider.min_value = GalaxySize.MIN
	height_slider.max_value = GalaxySize.MAX
	
	match index:
		MapSize.VERY_SMALL:
			galaxy_descr.text = "This galaxy size is perfect for beginners and short games. You will be playing with 3 AI."
			players_slider.value = 4
			systems_slider.value = 7
			_galaxy_map.players_count = 4
			_galaxy_map.systems_per_player = 7
			_calculate_galaxy_size()
			_set_map_size_to_min()
		
		MapSize.SMALL:
			galaxy_descr.text = "This galaxy size is perfect for beginners and short games. You will be playing with 5 AI."
			players_slider.value = 6
			systems_slider.value = 7
			_galaxy_map.players_count = 6
			_galaxy_map.systems_per_player = 7
			_calculate_galaxy_size()
			_set_map_size_to_min()
		
		MapSize.NORMAL:
			galaxy_descr.text = "This galaxy size is good for players with at least some experience on smaller maps. You will be playing with 7 AI."
			players_slider.value = 8
			systems_slider.value = 8
			_galaxy_map.players_count = 8
			_galaxy_map.systems_per_player = 8
			_calculate_galaxy_size()
			_set_map_size_to_min()
		
		MapSize.LARGE:
			galaxy_descr.text = "Good for experienced players and for longer games. You will be playing with 11 AI."
			players_slider.value = 12
			systems_slider.value = 8
			_galaxy_map.players_count = 12
			_galaxy_map.systems_per_player = 8
			_calculate_galaxy_size()
			_set_map_size_to_min()
		
		MapSize.VERY_LARGE:
			galaxy_descr.text = "Good for experienced players and for longer games. You will be playing with 15 AI."
			players_slider.value = 16
			systems_slider.value = 10
			_galaxy_map.players_count = 16
			_galaxy_map.systems_per_player = 10
			_calculate_galaxy_size()
			_set_map_size_to_min()
		
		MapSize.ENORMOUS:
			galaxy_descr.text = "Good for experienced players and for very long games. You will be playing with 19 AI."
			players_slider.value = 20
			systems_slider.value = 10
			_galaxy_map.players_count = 20
			_galaxy_map.systems_per_player = 10
			_calculate_galaxy_size()
			_set_map_size_to_min()
		
		MapSize.GALAXY:
			galaxy_descr.text = "Good for experienced players and for marathon games. You will be playing with 29 AI."
			players_slider.value = 30
			systems_slider.value = 12
			_galaxy_map.players_count = 30
			_galaxy_map.systems_per_player = 12
			_calculate_galaxy_size()
			_set_map_size_to_min()
		
		MapSize.CUSTOM:
			galaxy_descr.text = "In case any of the previous sizes doesn't fit your needs is this option."
			_calculate_galaxy_size()
			_enable_galaxy_settings(true)
		
		_: assert(false, "Unknown map size")
	
	_map_size = index


func _enable_galaxy_settings(enable: bool) -> void:
	players_slider.editable = enable
	systems_slider.editable = enable
	width_slider.editable = enable
	height_slider.editable = enable


func _calculate_galaxy_size() -> void:
	var min_size := int(sqrt(players_slider.value * systems_slider.value * SPACE_PER_PLANET) + 2)
	width_slider.min_value = min_size
	width_slider.tick_count = GalaxySize.MAX - min_size + 1
	height_slider.min_value = min_size
	height_slider.tick_count = GalaxySize.MAX - min_size + 1


func _set_map_size_to_min() -> void:
	width_slider.value = width_slider.min_value
	height_slider.value = width_slider.min_value


func _on_PlayersSlider_value_changed(value: float) -> void:
	players_val_lab.text = str(value)
	_calculate_galaxy_size()


func _on_SystemSlider_value_changed(value: float) -> void:
	systems_val_lab.text = str(value)
	_calculate_galaxy_size()


func _on_WidthSlider_value_changed(value: float) -> void:
	width_val_lab.text = str(value)
	_galaxy_map.width = value
	_calculate_x_range()


func _on_HeightSlider_value_changed(value: float) -> void:
	height_val_lab.text = str(value)
	_galaxy_map.height = value
	_calculate_y_range()


func _on_GenerateGalaxyButton_pressed() -> void:
	_galaxy_map.generate()
	Data.system_path = _galaxy_map.system_path
	Data.system_positions = _galaxy_map.system_positions
	Data.galaxy_rect = _galaxy_map.galaxy_rect
	minimap.update()


func _on_PreviewCheckBox_toggled(button_pressed: bool) -> void:
	galaxy_preview.visible = button_pressed
