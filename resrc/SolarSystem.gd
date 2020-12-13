class_name SolarSystem
extends Resource
"""
Script description
"""
################################################################# SIGNALS ################################################################
################################################################# ENUMS ##################################################################
################################################################# CONSTANTS ##############################################################
################################################################# EXPORT VAR #############################################################
export(String) var description
export(Texture) var texture		# Displayed on galaxy map
export(Texture) var icon		# Displayed on minimap
export(Texture) var background	# Displayed as a background in system view
export(Array, Resource) var uniqe_buildings	# Buildings that are unique to star in system
export(int, 0, 5) var min_planets setget set_min_planets
export(int, 0, 5) var max_planets setget set_max_planets

################################################################# PUBLIC VAR #############################################################
var name := ""

################################################################# PRIVATE VAR ############################################################
var _planets := {}
var _buildings := {}

################################################################# ONREADY VAR ############################################################
################################################################# SETTERS & GETTERS ######################################################
func set_min_planets(val: int) -> void:
	if val <= max_planets:
		min_planets = val
	else:
		max_planets = val
		min_planets = val


func set_max_planets(val: int) -> void:
	if val >= min_planets:
		max_planets = val
	else:
		min_planets = val
		max_planets = val


################################################################# BUILT-IN METHODS #######################################################
func add_building(building: Building) -> void:
	if !building.name in _buildings:
		_buildings[building.name] = building


################################################################# PUBLIC METHODS #########################################################
func generate() -> void:
	pass


################################################################# PRIVATE METHODS ########################################################
