tool
extends VisualScriptCustomNode

func _get_caption():
	return "Open Simplex Noise 3D"

func _get_category():
	return "Noise functions"

func _get_input_value_port_count():
	return 3

func _get_input_value_port_name(idx):
	if idx == 0:
		return "x, y, z"
	if idx == 1:
		return "Frequency"
	else:
		return "Seed"

func _get_input_value_port_type(idx):
	if idx == 0:
		return TYPE_VECTOR3
	if idx == 1:
		return TYPE_REAL
	else:
		return TYPE_INT

func _get_output_sequence_port_count():
	return 0

func _get_output_sequence_port_text(idx):
	return null

func _get_output_value_port_count():
	return 1

func _get_output_value_port_name(idx):
	return "Weight"

func _get_output_value_port_type(idx):
	return TYPE_REAL

func _get_text():
	return null

func _get_working_memory_size():
	return 0

func _has_input_sequence_port():
	return false

func _step(inputs, outputs, start_mode, working_mem):
	if inputs[2] != last_seed:
		_seed_changed(inputs[2])
		
	if inputs[1]:
		outputs[0] = SoftNoise.openSimplex3D(
			inputs[0].x * inputs[1],
			inputs[0].y * inputs[1],
			inputs[0].z * inputs[1]
		)
	else:
		outputs[0] = SoftNoise.openSimplex3D(
			inputs[0].x,
			inputs[0].y,
			inputs[0].z
		)
	return 0

var preScript = preload("SoftNoise.gd")
var SoftNoise

var last_seed = 0
func _seed_changed(new_seed):
	SoftNoise = preScript.SoftNoise.new(new_seed)
	last_seed = new_seed
	
func _init():
	_seed_changed(last_seed)


