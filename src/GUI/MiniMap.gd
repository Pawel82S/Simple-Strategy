#class_name
extends MarginContainer
"""
Script description
"""
################################################################# SIGNALS ################################################################
################################################################# ENUMS ##################################################################
################################################################# CONSTANTS ##############################################################
################################################################# EXPORT VAR #############################################################
################################################################# PUBLIC VAR #############################################################
################################################################# PRIVATE VAR ############################################################
################################################################# ONREADY VAR ############################################################
onready var grid := $Grid
onready var sprite := $Sprite
onready var line := $Line2D

################################################################# SETTERS & GETTERS ######################################################
################################################################# BUILT-IN METHODS #######################################################
################################################################# PUBLIC METHODS #########################################################
func update() -> void:
	if !Data.system_positions || !Data.system_path:
		return
	
	for child in grid.get_children():
		grid.remove_child(child)
	
	var grid_x_factor = grid.rect_size.x / Data.galaxy_rect.size.x
	var grid_y_factor = grid.rect_size.y / Data.galaxy_rect.size.y
#	print("Factor x: %f, factor y: %f" % [grid_x_factor, grid_y_factor])
	var grid_center_offset: Vector2 = grid.rect_size / 2
#	print("Grid center offset: %s" % grid_center_offset)
	for sys_pos in Data.system_positions:
		var grid_pos: Vector2 = sys_pos
		grid_pos.x *= grid_x_factor
		grid_pos.y *= grid_y_factor
		grid_pos += grid.rect_position + grid_center_offset
		var new_sprite := sprite.duplicate()
		grid.add_child(new_sprite)
		new_sprite.position = grid_pos
#		print(grid_pos)
		new_sprite.show()
	
	var planet_sprites := grid.get_children()
	for id in range(Data.system_positions.size()):
		var from_pos: Vector2 = grid.get_child(id).position
		var system_connections := Data.system_path.get_point_connections(id)
#		print("System %d, has %d connections" % [id, system_connections.size()])
		for connection_id in system_connections:
			if connection_id < id:
				continue
			
			var new_line := line.duplicate()
			grid.add_child(new_line)
			new_line.add_point(from_pos)
			var to_pos: Vector2 = grid.get_child(connection_id).position
			new_line.add_point(to_pos)
			new_line.show()

################################################################# PRIVATE METHODS ########################################################
