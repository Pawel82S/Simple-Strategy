class_name Building
extends Resource
"""
Script description
"""
################################################################# SIGNALS ################################################################
################################################################# ENUMS ##################################################################
enum Purpose {
	PLANETARY,
	SYSTEM,
}

enum Type {
	NORMAL,
	UNIQUE,
}

################################################################# CONSTANTS ##############################################################
################################################################# EXPORT VAR #############################################################
export(Purpose) var purpose
export(Type) var type

################################################################# PUBLIC VAR #############################################################
var name := ""

################################################################# PRIVATE VAR ############################################################
################################################################# ONREADY VAR ############################################################
################################################################# SETTERS & GETTERS ######################################################
################################################################# BUILT-IN METHODS #######################################################
################################################################# PUBLIC METHODS #########################################################
################################################################# PRIVATE METHODS ########################################################