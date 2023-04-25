## Utilities for working with 3D surfaces.

class Vertex:
	var vertex : Vector3
	var id : int
	func _init(_vertex, _id) -> void:
		id = _id
		vertex = _vertex


## Join the vertices that have the same position.
## Returns a [Dictionary] with two keys:[br]
## [code]mesh[/code]: The result mesh[br]
## [code]original_ids[/code]: A map of the original vertex ids to the new ones
static func join_duplicates(mesh : Mesh, surface : int) -> Dictionary:
	var data_tool := MeshDataTool.new()
	if not data_tool.create_from_surface(mesh, surface) == OK:
		return {}
	
	var ordered_vertices : Array[Vertex] = []
	for vertex_id in data_tool.get_vertex_count():
		var vertex := data_tool.get_vertex(vertex_id)
		ordered_vertices.append(Vertex.new(vertex, vertex_id))
	ordered_vertices.sort_custom(
		func(a : Vertex, b : Vertex) -> bool:
			return a.vertex > b.vertex)
	
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var original_ids := {}
	var new_ids := {}
	var current_id := -1
	var last_vertex
	
	for vertex in ordered_vertices:
		if last_vertex == null or not last_vertex.is_equal_approx(vertex.vertex):
			surface_tool.set_color(Color(vertex.id))
			surface_tool.add_vertex(vertex.vertex)
			current_id += 1
			last_vertex = vertex.vertex
			original_ids[current_id] = []
		original_ids[current_id].append(vertex.id)
		new_ids[vertex.id] = current_id
	
	for face in data_tool.get_face_count():
		for v in [
				data_tool.get_face_vertex(face, 0),
				data_tool.get_face_vertex(face, 1),
				data_tool.get_face_vertex(face, 2)]:
			surface_tool.add_index(new_ids[v])
	
	return {
		mesh = surface_tool.commit(),
		original_ids = original_ids,
	}


## Returns an approximation of the size of pixels in world-space.
## It currently measures the first edge and assumes the mesh has
## uniform texel density.
static func get_texel_density(mesh : Mesh) -> float:
	var data_tool := MeshDataTool.new()
	data_tool.create_from_surface(mesh, 0)
	var v1 := data_tool.get_edge_vertex(0, 0)
	var v2 := data_tool.get_edge_vertex(0, 1)
	var world_length := data_tool.get_vertex(v1).distance_to(data_tool.get_vertex(v2))
	var texture_length := data_tool.get_vertex_uv(v1).distance_to(data_tool.get_vertex_uv(v2))
	## TODO: Double-check if this math checks out.
	return world_length / texture_length
