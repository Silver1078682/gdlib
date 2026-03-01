class_name DictUtil

## Filter keys based on a given method.
## The method should return a boolean value.
static func filter_keys(dict: Dictionary, method: Callable) -> void:
	for i in dict:
		if not method.call(i):
			dict.erase(i)

## Filter values based on a given method.
## The method should return a boolean value.
static func filter_values(dict: Dictionary, method: Callable) -> void:
	for i in dict:
		if not method.call(dict[i]):
			dict.erase(i)

## Compose a dictionary from two arrays.[br]
## If the arrays are not of the same length
## The resulting dictionary will only contain as many elements as the shorter array.
## If a key is repeated, only the last value will be kept. (last seen win)
static func compose(keys: Array, values: Array) -> Dictionary:
	var result = {}
	var size := keys.size()
	if keys.size() != values.size():
		push_warning("Keys and values arrays must be of the same length.")
		size = min(keys.size(), values.size())

	for i in size:
		result[keys[i]] = values[i]
	return result

## Reverse the keys and values of the given dictionary.
static func reverse(dict: Dictionary) -> Dictionary:
	var result = {}
	for key in dict:
		result[dict[key]] = key
	return result