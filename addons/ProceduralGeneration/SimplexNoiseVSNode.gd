tool
extends VisualScriptCustomNode

func _get_caption():
	return "Open Simplex Noise 2D"

func _get_category():
	return "Procedural generation"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_name(idx):
	return "Terrain Position"

func _get_input_value_port_type(idx):
	return TYPE_VECTOR2

func _get_output_sequence_port_count():
	return 1

#func _get_output_sequence_port_text(idx):
# pass

func _get_output_value_port_count():
	return 1

func _get_output_value_port_name(idx):
	return "Weight"

func _get_output_value_port_type(idx):
	return TYPE_REAL

#func _get_text():
#	return "test text"

func _get_working_memory_size():
	return 0

func _has_input_sequence_port():
	return true

func _step(inputs, outputs, start_mode, working_mem):
	outputs[0] = SoftNoise.openSimplex2D(inputs[0].x, inputs[0].y)
	return 0

var preScript = preload("SoftNoise.gd")
var SoftNoise
func _seed_changed(newSeed):
	SoftNoise = preScript.SoftNoise.new(newSeed)
	
func _init():
	_seed_changed(14)


