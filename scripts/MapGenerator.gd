tool
extends Spatial

export(bool) var regenerate_mesh = true

export(int) var chunk_resolution = 16 setget _set_chunk_resolution
func _set_chunk_resolution(new_chunk_resolution):
	chunk_resolution = new_chunk_resolution
	recalculate_hidden_parameters()
	
export(float) var square_size = 0.25 setget _set_square_size
func _set_square_size(new_square_size):
	square_size = new_square_size
	recalculate_hidden_parameters()
	
var chunk_size = chunk_resolution * square_size
	
export(Vector3) var generate_around

export(float) var load_range = 64.0 setget _set_chunk_load_range
var chunk_load_range = load_range / chunk_resolution * square_size
func _set_chunk_load_range(new_load_range):
	load_range = new_load_range
	recalculate_hidden_parameters()

export(float) var unload_range = 128.0 setget _set_chunk_unload_range
var chunk_unload_range = unload_range / chunk_resolution * square_size
func _set_chunk_unload_range(new_unload_range):
	unload_range = new_unload_range
	recalculate_hidden_parameters()

export(float) var uncache_range = 256.0 setget _set_chunk_uncache_range
var chunk_uncache_range = uncache_range / chunk_resolution * square_size
func _set_chunk_uncache_range(new_uncache_range):
	uncache_range = new_uncache_range
	recalculate_hidden_parameters()

func recalculate_hidden_parameters():
	chunk_size = chunk_resolution * square_size
	chunk_load_range = load_range / chunk_size
	chunk_unload_range = unload_range / chunk_size
	chunk_uncache_range = uncache_range / chunk_size
	
var SoftNoise = preload("res://scripts/SoftNoise.gd").SoftNoise

export(VisualScript) var noise_function

export(bool) var generate_model = true
export(bool) var generate_body = false

func vlerp(a, b, c):
	return Vector3(
		lerp(a.x, b.x, c),
		lerp(a.y, b.y, c),
		lerp(a.z, b.z, c)
	)

func generate_chunk_mesh(chunk):
	var temp_mesh_array = []
	
	for x in range(chunk_resolution + 1):
		temp_mesh_array.append([])
		for y in range(chunk_resolution + 1):
			temp_mesh_array[x].append(vs_executer.noise(Vector2(
				chunk.x * chunk_resolution * square_size + x * square_size, 
				chunk.y * chunk_resolution * square_size + y * square_size 
			)))
	
	var mesh = SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	mesh.add_uv(Vector2(0, 0))
	
	var offset = Vector3(chunk_size / 2, 0, chunk_size / 2)
	
	for x in range(chunk_resolution):
		for y in range(chunk_resolution):
			var mesh_point = temp_mesh_array[x][y] / 10
			var mesh_vec = vlerp(Vector3(0, 0.3, 0.1), Vector3(1, 1, 1), mesh_point)
			var mesh_color = Color(mesh_vec.x, mesh_vec.y, mesh_vec.z)
				
			mesh.add_color(mesh_color)
			
			mesh.add_vertex(Vector3(
				x * square_size, temp_mesh_array[x][y], y * square_size
			) - offset)
			mesh.add_vertex(Vector3(
				(x + 1) * square_size, temp_mesh_array[x + 1][y], y * square_size
			) - offset)
			mesh.add_vertex(Vector3(
				x * square_size, temp_mesh_array[x][y + 1], (y + 1) * square_size
			) - offset)
			
			mesh.add_vertex(Vector3(
				x * square_size, temp_mesh_array[x][y + 1], (y + 1) * square_size
			) - offset)
			mesh.add_vertex(Vector3(
				(x + 1) * square_size, temp_mesh_array[x + 1][y], y * square_size
			) - offset)
			mesh.add_vertex(Vector3(
				(x + 1) * square_size, temp_mesh_array[x + 1][y + 1], (y + 1) * square_size
			) - offset)
	
	return mesh.commit()
	
var chunk_cache = {}	

func generate_chunk(chunk):
	if not chunk_cache.has(chunk.x):
		chunk_cache[chunk.x] = {}
	
	var mesh = generate_chunk_mesh(chunk)
	if generate_model:
		var mesh_instance = MeshInstance.new()
		mesh_instance.name = str("mesh_", chunk.x, "_", chunk.y)
		add_child(mesh_instance)
		mesh_instance.mesh = mesh
		mesh_instance.set_surface_material(0, debug_material)
		mesh_instance.translation = Vector3(
			chunk.x * chunk_size, 0, chunk.y * chunk_size
		)
		
		chunk_cache[chunk.x][chunk.y] = mesh_instance
	
	return chunk_cache[chunk.x][chunk.y]
	
# Where I figure out where to generate

func point_to_chunk(point):
	return Vector2(point.x / chunk_size, point.y / chunk_size)

func generate_around_point(point):
	var point_chunk = point_to_chunk(point)
	
	for x in range(point_chunk.x - chunk_load_range, point_chunk.x + chunk_load_range + 1):
		if not chunk_cache.has(x):
			chunk_cache[x] = {}
		for y in range(point_chunk.y - chunk_load_range, point_chunk.y + chunk_load_range + 1):
			var distance_to_chunk = Vector2(x, y) - point_chunk
			if abs(distance_to_chunk.length()) < chunk_load_range:
				if not chunk_cache[x].has(y):
					generate_chunk(Vector2(x, y))

# DEBUG ZONE

var debug_material

func regen_mesh(newvar):
	for child in get_children():
		if child is MeshInstance:
			child.queue_free()
			
	generate_around_point(Vector2(0, 0))

var vs_executer

func _ready():
	vs_executer = Node.new()
	vs_executer.name = "VS executer"
	vs_executer.set_script(noise_function)
	add_child(vs_executer)
	print(vs_executer.has_method("noise"))
	
	var test = load("res://scripts/SoftNoise.gd").SoftNoise.new(123)
	debug_material = SpatialMaterial.new()
	debug_material.vertex_color_use_as_albedo = true
	regen_mesh(12)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	