extends Node2D

var speed: = 0.0

const Bomb: = preload('res://Bomb.tscn')

func _get_local_input() -> Dictionary:
	var input_vector: = Input.get_vector('ui_left', 'ui_right', 'ui_up', 'ui_down')

	var input: = {}
	if input_vector != Vector2.ZERO:
		input['input_vector'] = input_vector
	if Input.is_action_just_pressed('ui_accept'):
		input['drop_bomb'] = true

	return input


func _predict_remote_input(previous_input: Dictionary, _ticks_since_real_input: int) -> Dictionary:
	var input: = previous_input.duplicate()
	input.erase('drop_bomb')
	return input


func _network_process(input: Dictionary) -> void:
	var input_vector: Vector2 = input.get('input_vector', Vector2.ZERO)
	if input_vector != Vector2.ZERO:
		if speed < 8.0:
			speed += 0.2
		position += input_vector * speed
	else:
		speed = 0.0
	if input.has('drop_bomb'):
		SyncManager.spawn('Bomb', get_parent(), Bomb, { position = global_position })


func _save_state() -> Dictionary:
	return {
		position = position,
		speed = speed,
	}


func _load_state(state: Dictionary) -> void:
	position = state['position']
	speed = state['speed']
