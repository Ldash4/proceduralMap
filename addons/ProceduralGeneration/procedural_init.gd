tool
extends EditorPlugin

func _enter_tree():
	VisualScriptEditor.add_custom_node("Open Simplex 2D", "Noise functions", preload("OpenSimplexNoise2D_VS.gd"))
	VisualScriptEditor.add_custom_node("Open Simplex 3D", "Noise functions", preload("OpenSimplexNoise3D_VS.gd"))
	add_custom_type("Terrain Generator", "Spatial", preload("terrain_generator_node.gd"), preload("terrain_generator_node.png"))
		
func _exit_tree():
	VisualScriptEditor.remove_custom_node("Open Simplex 2D", "Noise functions")
	VisualScriptEditor.remove_custom_node("Open Simplex 3D", "Noise functions")