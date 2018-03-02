tool
extends EditorPlugin

func _enter_tree():
		VisualScriptEditor.add_custom_node("Open Simplex 2D", "Procedural generation", preload("res://addons/ProceduralGeneration/SimplexNoiseVSNode.gd"))

func _exit_tree():
		VisualScriptEditor.remove_custom_node("Open Simplex 2D", "Procedural generation")