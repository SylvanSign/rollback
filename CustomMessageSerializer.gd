extends 'res://addons/godot-rollback-netcode/MessageSerializer.gd'

const input_path_mapping: = {
	'/root/Main/ServerPlayer': 1,
	'/root/Main/ClientPlayer': 2,
}

const input_path_mapping_reversed: = {}

enum HeaderFlags {
	HAS_INPUT_VECTOR = 1,
	DROP_BOMB = 2,
}

func _init() -> void:
	for key in input_path_mapping:
		input_path_mapping_reversed[input_path_mapping[key]] = key


func serialize_input(all_input: Dictionary) -> PoolByteArray:
	var buffer: = StreamPeerBuffer.new()
	buffer.resize(16)

	# input hash
	buffer.put_u32(all_input['$'])
	# generic count of rest of keys (besides input hash above)
	buffer.put_u8(all_input.size() - 1)
	for path in all_input:
		# skip over input hash (see above)
		if path == '$':
			continue

		buffer.put_u8(input_path_mapping[path])

		var header: = 0

		var input: Dictionary = all_input[path]
		var has_input_vector: = input.has('input_vector')
		if has_input_vector:
			header |= HeaderFlags.HAS_INPUT_VECTOR
			if input.has('drop_bomb'):
				header |= HeaderFlags.DROP_BOMB

		buffer.put_u8(header)

		if has_input_vector:
			var input_vector: Vector2 = input['input_vector']
			buffer.put_float(input_vector.x)
			buffer.put_float(input_vector.y)

	buffer.resize(buffer.get_position())
	return buffer.data_array


func unserialize_input(serialized: PoolByteArray) -> Dictionary:
	var buffer: = StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)

	var all_input: = {}

	all_input['$'] = buffer.get_u32()

	var input_count: = buffer.get_u8()

	for i in input_count:
		var path: String = input_path_mapping_reversed[buffer.get_u8()]
		var input: = {}

		var header = buffer.get_u8()
		if header & HeaderFlags.HAS_INPUT_VECTOR:
			input['input_vector'] = Vector2(buffer.get_float(), buffer.get_float())
		if header & HeaderFlags.DROP_BOMB:
			input['drop_bomb'] = true

		all_input[path] = input

	return all_input
