#class_name
extends Control
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
################################################################# SETTERS & GETTERS ######################################################
################################################################# BUILT-IN METHODS #######################################################
################################################################# PUBLIC METHODS #########################################################
################################################################# PRIVATE METHODS ########################################################
func _on_ContinueGameButton_pressed() -> void:
	pass # Replace with function body.


func _on_NewGameButton_pressed() -> void:
	get_tree().change_scene("res://src/GUI/NewGameMenu/NewGameMenu.tscn")


func _on_LoadGameButton_pressed() -> void:
	pass # Replace with function body.


func _on_SaveGameButton_pressed() -> void:
	pass # Replace with function body.


func _on_GameSettingsButton_pressed() -> void:
	pass # Replace with function body.


func _on_QuitGameButton_pressed() -> void:
	get_tree().quit()
