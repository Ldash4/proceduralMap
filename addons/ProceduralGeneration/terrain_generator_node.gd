tool
extends Spatial

# ----------------TODO:----------------

# Custom class for script executor that
# has builtin static functions.
# Update: seems to be not possible due
# to vs script not being aware of
# static methods in the node, since it
# is not yet attached.

# Use more noise functions for
# generation of uv, uv2, and color.

# Custom class for the whole generator.
# Can I make it load with position?

# Load chunks one at a time in radius

# Unload chunks outside of radius

# Write chunks to file outside of
# radius.
# Should be able to detect change in
# terrain algorith, and delete cache

# Fix the camera

# Make terrain function return 0-1 and
# pass it to color function, then
# multiply later.

export(Material) var terrain_material

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

export(float) var load_range = 32.0 setget _set_chunk_load_range
var chunk_load_range = load_range / chunk_resolution * square_size
func _set_chunk_load_range(new_load_range):
	load_range = new_load_range
	recalculate_hidden_parameters()

export(float) var unload_range = 64.0 setget _set_chunk_unload_range
var chunk_unload_range = unload_range / chunk_resolution * square_size
func _set_chunk_unload_range(new_unload_range):
	unload_range = new_unload_range
	recalculate_hidden_parameters()

export(float) var uncache_range = 128.0 setget _set_chunk_uncache_range
var chunk_uncache_range = uncache_range / chunk_resolution * square_size
func _set_chunk_uncache_range(new_uncache_range):
	uncache_range = new_uncache_range
	recalculate_hidden_parameters()

func recalculate_hidden_parameters():
	chunk_size = chunk_resolution * square_size
	chunk_load_range = load_range / chunk_size
	chunk_unload_range = unload_range / chunk_size
	chunk_uncache_range = uncache_range / chunk_size

export(bool) var generate_model = true
export(bool) var generate_physics = false

func vlerp(a, b, c):
	return Vector3(
		lerp(a.x, b.x, c),
		lerp(a.y, b.y, c),
		lerp(a.z, b.z, c)
	)
	
func add_all_attributes(mesh, vertex, uv, uv2, color):
	mesh.add_uv(uv)
	mesh.add_uv2(uv2)
	mesh.add_color(color)
	mesh.add_vertex(vertex)

export(float) var terrain_height_multiplier = 1.0

func generate_chunk_mesh(chunk):
	var temp_mesh_array = []
	
	for x in range(chunk_resolution + 1):
		temp_mesh_array.append([])
		for y in range(chunk_resolution + 1):
			temp_mesh_array[x].append({
				"height": 0,
				"uv": Vector2(),
				"uv2": Vector2(),
				"color": Color()
			})
			
			var chunk_point = Vector2(
				chunk.x * chunk_resolution * square_size + x * square_size, 
				chunk.y * chunk_resolution * square_size + y * square_size 
			)
			
			if vs_executer_has_terrain:
				temp_mesh_array[x][y].height = vs_executer.terrain(chunk_point)
			if vs_executer_has_uv:
				temp_mesh_array[x][y].uv = vs_executer.uv(chunk_point, temp_mesh_array[x][y].height)
			if vs_executer_has_uv2:
				temp_mesh_array[x][y].uv2 = vs_executer.uv2(chunk_point, temp_mesh_array[x][y].height)
			if vs_executer_has_color:
				temp_mesh_array[x][y].color = vs_executer.color(chunk_point, temp_mesh_array[x][y].height)
				
			temp_mesh_array[x][y].height *= terrain_height_multiplier
				
	var mesh = SurfaceTool.new()
	mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	mesh.add_uv(Vector2(0, 0))
	
	if terrain_material:
		mesh.set_material(terrain_material)
	
	var offset = Vector3(chunk_size / 2, 0, chunk_size / 2)
	
	for x in range(chunk_resolution):
		for y in range(chunk_resolution):
			
			add_all_attributes(mesh, Vector3(
				x * square_size, temp_mesh_array[x][y].height, y * square_size) - offset, 
				temp_mesh_array[x][y].uv, temp_mesh_array[x][y].uv2, 
				temp_mesh_array[x][y].color
			)
			
			add_all_attributes(mesh, Vector3(
				(x + 1) * square_size, temp_mesh_array[x + 1][y].height, y * square_size) - offset,
			 	temp_mesh_array[x + 1][y].uv, temp_mesh_array[x + 1][y].uv2, 
				temp_mesh_array[x + 1][y].color
			)
			
			add_all_attributes(mesh, Vector3(
				x * square_size, temp_mesh_array[x][y + 1].height, (y + 1) * square_size) - offset,
				temp_mesh_array[x][y + 1].uv, temp_mesh_array[x][y + 1].uv2, 
				temp_mesh_array[x][y + 1].color
			)
			
			add_all_attributes(mesh, Vector3(
				x * square_size, temp_mesh_array[x][y + 1].height, (y + 1) * square_size) - offset,
				temp_mesh_array[x][y + 1].uv, temp_mesh_array[x][y + 1].uv2, 
				temp_mesh_array[x][y + 1].color
			)
			
			add_all_attributes(mesh, Vector3(
				(x + 1) * square_size, temp_mesh_array[x + 1][y].height, y * square_size)	- offset,
				temp_mesh_array[x + 1][y].uv, temp_mesh_array[x + 1][y].uv2, 
				temp_mesh_array[x + 1][y].color
			)
			
			add_all_attributes(mesh, Vector3(
				(x + 1) * square_size, temp_mesh_array[x + 1][y + 1].height, (y + 1) * square_size) - offset,
				temp_mesh_array[x + 1][y + 1].uv, temp_mesh_array[x + 1][y + 1].uv2, 
				temp_mesh_array[x + 1][y + 1].color
			)
	
	mesh.generate_normals()
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
		mesh_instance.set_surface_material(0, terrain_material)
		mesh_instance.translation = Vector3(
			chunk.x * chunk_size, 0, chunk.y * chunk_size
		)
		
		chunk_cache[chunk.x][chunk.y] = mesh_instance
	
	return chunk_cache[chunk.x][chunk.y]
	
# Where I figure out where to generate

func point_to_chunk(point):
	return Vector2(point.x / chunk_size, point.y / chunk_size)
	
func get_unloaded_chunk_around(point):
	var point_chunk = point_to_chunk(point)
	
	for x in range(point_chunk.x - chunk_load_range, point_chunk.x + chunk_load_range + 1):
		if not chunk_cache.has(x):
			chunk_cache[x] = {}
		for y in range(point_chunk.y - chunk_load_range, point_chunk.y + chunk_load_range + 1):
			var distance_to_chunk = Vector2(x, y) - point_chunk
			if abs(distance_to_chunk.length()) < chunk_load_range:
				if not chunk_cache[x].has(y):
					return Vector2(x, y)
					

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

func regen_mesh():
	for child in get_children():
		if child is MeshInstance:
			child.queue_free()
			
	generate_around_point(Vector2(0, 0))

var vs_executer
var vs_executer_has_terrain
var vs_executer_has_uv
var vs_executer_has_uv2
var vs_executer_has_color
export(VisualScript) var noise_function

func _ready():
	vs_executer = Node.new()
	vs_executer.name = "VS executer"
	vs_executer.set_script(noise_function)
	add_child(vs_executer)
	
	vs_executer_has_terrain = vs_executer.has_method("terrain") and vs_executer.terrain(Vector2()) != null
	vs_executer_has_uv			= vs_executer.has_method("uv")			and vs_executer.uv(Vector2(), 0) != null
	vs_executer_has_uv2			= vs_executer.has_method("uv2")			and vs_executer.uv2(Vector2(), 0) != null
	vs_executer_has_color		= vs_executer.has_method("color")		and vs_executer.color(Vector2(), 0) != null
	
	regen_mesh()