class_name GalaxyGenerator
extends Reference
"""
This script is responsible for placing systems on map and making connections between them. Like in many TBS ships here travelling thru
starlanes.
"""
################################################################# SIGNALS ################################################################
################################################################# ENUMS ##################################################################
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
const MIN_SYSTEM_SEPARATION := 1
const MIN_PLANET_AREA := 9
const MIN_PLAYERS := 1
const MIN_CONNECTION_RANGE := 3

################################################################# EXPORT VAR #############################################################
################################################################# PUBLIC VAR #############################################################
var players_count := MIN_PLAYERS setget set_players_count
var systems_per_player: int = PlantetCount.MIN setget set_systems_per_player
var system_separation := MIN_SYSTEM_SEPARATION setget set_system_separation
var width: int = GalaxySize.MIN setget set_width
var height: int = GalaxySize.MIN setget set_height
var system_positions := [] setget set_system_positions, get_system_positions
var system_path := AStar2D.new() setget set_system_path, get_system_path
var galaxy_rect := Rect2(-abs(GalaxySize.MIN / 2), -abs(GalaxySize.MIN / 2), GalaxySize.MIN, GalaxySize.MIN) setget set_galaxy_rect

################################################################# PRIVATE VAR ############################################################
var _galaxy_ready := false
var _connection_points := {}
var _connection_range := Vector2(MIN_CONNECTION_RANGE, MIN_CONNECTION_RANGE)

################################################################# ONREADY VAR ############################################################
################################################################# SETTERS & GETTERS ######################################################
func set_players_count(val: int) -> void:
	assert(val >= MIN_PLAYERS, "Cannot create galaxy for %d or less players. You requested: %d." % [MIN_PLAYERS, val])
	if val != players_count:
		_galaxy_ready = false
		players_count = val


func set_systems_per_player(val: int) -> void:
	assert(val >= PlantetCount.MIN && val <= PlantetCount.MAX)
	if val != systems_per_player:
		_galaxy_ready = false
		systems_per_player = val


func set_system_separation(val: int) -> void:
	assert(val >= MIN_SYSTEM_SEPARATION)
	if val != system_separation:
		_galaxy_ready = false
		system_separation = val


func set_width(val: int) -> void:
	assert(val >= GalaxySize.MIN && val <= GalaxySize.MAX)
	if val != width:
		_galaxy_ready = false
		width = val
		galaxy_rect.position.x = -val / 2
		galaxy_rect.size.x = val


func set_height(val: int) -> void:
	assert(val >= GalaxySize.MIN && val <= GalaxySize.MAX)
	if val != height:
		_galaxy_ready = false
		height = val
		galaxy_rect.position.y = -val / 2
		galaxy_rect.size.y = val


func set_system_positions(_v) -> void:
	assert(false, "You cannot set this variable outside of script. It's read only.")


func get_system_positions() -> Array:
	if !_galaxy_ready:
		generate()
	return system_positions


func set_system_path(_v) -> void:
	assert(false, "You cannot set this variable outside of script. It's read only.")


func get_system_path() -> AStar2D:
	if !_galaxy_ready:
		generate()
	return system_path


func set_galaxy_rect(_v) -> void:
	assert(false, "You cannot set this variable outside of script. It's read only.")

################################################################# BUILT-IN METHODS #######################################################
################################################################# PUBLIC METHODS #########################################################
func generate() -> void:
	system_positions.clear()
	system_path.clear()
	_connection_points.clear()
	_generate_system_positions()
	_generate_system_connections()
	_galaxy_ready = true

################################################################# PRIVATE METHODS ########################################################
# TODO: Improve separation and connection vectors calculation
func _generate_system_positions() -> void:
	var systems_to_generate := players_count * systems_per_player
	var availble_positions := _empty_galaxy_positions()
	# FIXME: Separation and connection vectors should depend on galaxy size and number of systems
	var separation_vectors := _get_vectors_in_range(system_separation, system_separation, false)
	var connection_vectors := _get_vectors_in_range(_connection_range.x, _connection_range.y, false)
	for sys_id in range(systems_to_generate):
		if availble_positions.empty():
			break
		
		var sys_pos: Vector2 = availble_positions[randi() % availble_positions.size()]
		system_positions.append(sys_pos)
		system_path.add_point(sys_id, sys_pos)
		availble_positions.erase(sys_pos)
		
		for vec in separation_vectors:
			availble_positions.erase(sys_pos + vec)
		
		for vec in connection_vectors:
			var new_pos: Vector2 = sys_pos + vec
			if !_connection_points.has(new_pos):
				_connection_points[new_pos] = []
			_connection_points[new_pos].append(sys_id)


func _empty_galaxy_positions() -> Array:
	var result := []
	
	for x in range(galaxy_rect.position.x, galaxy_rect.end.x + 1):
		for y in range(galaxy_rect.position.y, galaxy_rect.end.y + 1):
			result.append(Vector2(x, y))
	
	return result


func _get_vectors_in_range(to_x: int, to_y: int, include_center: bool = true, from_x: int = 0, from_y: int = 0) -> Array:
	assert(to_x > 0 && to_y > 0 && from_x >= 0 && from_y >= 0)
	assert(from_x < to_x && from_y < to_y)
	var result := []
	
	for pos_x in range(from_x, to_x + 1):
		for pos_y in range(from_y, to_y + 1):
			if pos_x == 0 && pos_y == 0:
				if include_center:
					result.append(Vector2.ZERO)
				else:
					continue
			elif pos_x == 0:
				result.append(Vector2(0, pos_y))
				result.append(Vector2(0, -pos_y))
			elif pos_y == 0:
				result.append(Vector2(pos_x, 0))
				result.append(Vector2(-pos_x, 0))
			else:
				result.append(Vector2(pos_x, pos_y))
				result.append(Vector2(-pos_x, pos_y))
				result.append(Vector2(pos_x, -pos_y))
				result.append(Vector2(-pos_x, -pos_y))
	
	return result


func _generate_system_connections() -> void:
	for current_sys_id in system_positions.size():
		var current_sys_pos: Vector2 = system_positions[current_sys_id]
		var current_sys_connection_ids := system_path.get_point_connections(current_sys_id)
		if current_sys_connection_ids.size() >= ConnectionsPerSystem.MAX:
			continue
		
		var possible_connection_ids := []
		if _connection_points.has(current_sys_pos):
			possible_connection_ids = _connection_points[current_sys_pos]
		
		if possible_connection_ids.empty():
			# Search for possible connections
			possible_connection_ids = _extend_search_connections(current_sys_pos, Vector2.ONE)
		
		for target_id in possible_connection_ids:
			if !target_id in current_sys_connection_ids && current_sys_connection_ids.size() < ConnectionsPerSystem.MAX:
				system_path.connect_points(current_sys_id, target_id)
				#NOTE: I have to update current system connections because it's passed by value not reference from get_point_connections
				current_sys_connection_ids = system_path.get_point_connections(current_sys_id)
		
	_connect_separate_system_groups()


func _extend_search_connections(current_sys_pos: Vector2, extension_range: Vector2) -> Array:
	var result := []
	var to_x := _connection_range.x + extension_range.x
	var to_y := _connection_range.y + extension_range.y
	var connection_vectors := _get_vectors_in_range(to_x, to_y, false, _connection_range.x, _connection_range.y)
	for vec in connection_vectors:
		var tested_pos: Vector2 = current_sys_pos + vec
		if tested_pos in system_positions:
			var tested_sys_id := system_path.get_closest_point(tested_pos)
			if system_path.get_point_connections(tested_sys_id).size() < ConnectionsPerSystem.MAX:
				result.append(tested_sys_id)
	if !result.empty():
		return result
	else:
		return _extend_search_connections(current_sys_pos, extension_range + Vector2.ONE)


func _connect_separate_system_groups() -> void:
	var group: PoolIntArray = _get_group_ids(0)	# I have to start somwhere
	while group.size() != system_positions.size():
		for id in system_positions.size():
			if !id in group:
				var sub_group: PoolIntArray = _get_group_ids(id)
				_make_best_connection(group, sub_group)
				group.append_array(sub_group)
	
	if group.size() == system_positions.size():
		print("All groups connected")
	else:
		print("Not all groups connected. Something went wrong.")


func _get_group_ids(start_id: int, travelled_ids: Array = []) -> Array:
	travelled_ids.append(start_id)
	var neighbours := system_path.get_point_connections(start_id)
	for neighbour in neighbours:
		if !neighbour in travelled_ids:
			travelled_ids = _get_group_ids(neighbour, travelled_ids)
	return travelled_ids


#NOTE: This function checks all possible options for connections. For now I don't know smarter and faster way of acheving this.
func _make_best_connection(from_group: Array, to_group: Array) -> void:
	var valid_ids_from_group := _get_system_ids_with_free_connections(from_group)
	var valid_ids_to_group := _get_system_ids_with_free_connections(to_group)
	var best_distance := 9999999999999999.9
	var best_from_id := 0
	var best_to_id := 0
	for from_id in valid_ids_from_group:
		for to_id in valid_ids_to_group:
			var from_pos: Vector2 = system_positions[from_id]
			var to_pos: Vector2 = system_positions[to_id]
			var distance := from_pos.distance_squared_to(to_pos)
			if distance < best_distance:
				best_from_id = from_id
				best_to_id = to_id
				best_distance = distance
	system_path.connect_points(best_from_id, best_to_id)


func _get_system_ids_with_free_connections(group: Array) -> Array:
	var result := []
	for id in group:
		if system_path.get_point_connections(id).size() < ConnectionsPerSystem.MAX:
			result.append(id)
	return result
