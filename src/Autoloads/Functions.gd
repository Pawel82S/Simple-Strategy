extends Node

# Apply function to each element of array and return new array with results.
# Input array isn't modified. Example:
#
# var input_arr := [0, 1, 2, 3, 4]
# var new_arr = map(input_arr, funcref(self, "add_one"))
# print(new_arr) # this will output [1, 2, 3, 4, 5]
#
# func add_one(element):
#	return element + 1
static func map(array: Array, function: FuncRef) -> Array:
	var result := []
	var size := array.size()
	result.resize(size)
	
	for i in range(size):
		result[i] = function.call_func(array[i])
	
	return result


# Filter array by provided function and return new array with results.
# Input array isn't modified. Example:
#
# var input_arr := [1, 2, 3, 4, 5]
# var filtered_arr = filter(input_arr, funcref(self, "is_even"))
# print(filtered_arr) # this will output [2, 4]
#
# func is_even(element: int) -> bool:
#	return true if element % 2 == 0 else false
static func filter(array: Array, function: FuncRef) -> Array:
	var result := []
	
	for elem in array:
		if function.call_func(elem):
			result.append(elem)
	
	return result


static func reduce(array: Array, function: FuncRef, base = null):
	var accumulator = base
	var index := 0
	var arr_size := array.size()
	
	if !base && arr_size > 0:
		accumulator = array[0]
		index = 1
	
	while index < arr_size:
		accumulator = function.call_func(accumulator, array[index])
		index += 1
	
	return accumulator


static func randi_from_range(from: float, to: float) -> int:
	assert(to > from)
	var num := int(to - from + 1)
	return int(randi() % num + from)


static func randf_from_range(from: float, to: float) -> float:
	assert(to > from)
	return rand_range(from, to)


static func celsius_from_kelvin(temp: float) -> float:
	return temp - 273.15


static func celsius_from_farenheit(temp: float) -> float:
	return (temp - 32) * 5 / 9


static func farenheit_from_kelvin(temp: float) -> float:
	return temp * 9 / 5 - 459.67


static func farenheit_from_celsius(temp: float) -> float:
	return temp * 9 / 5 + 32


static func kelvin_from_celsius(temp: float) -> float:
	return temp + 273.15


static func kelvin_from_farenheit(temp: float) -> float:
	return (temp + 459.67) * 5 / 9


static func ignore_result(_r) -> void:
	pass
