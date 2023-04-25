## Utility to get the curvature of edges of a mesh.

## Returns the curvature of edges as integers ranging from -1 to 1.
## The index of the array is the edge id.
static func get_edge_curvatures(mesh_tool : MeshDataTool) -> Array[int]:
	# TODO: Replace curvature calculation with this:
	# https://math.stackexchange.com/questions/4509162/angle-between-two-directed-triangles-in-3d-between-0-an-2-pi
	# Remove the 'Issues' section in the readme afterwards.
	var edge_curvatures : Array[int] = []
	edge_curvatures.resize(mesh_tool.get_edge_count())
	for edge in mesh_tool.get_edge_count():
		var faces := mesh_tool.get_edge_faces(edge)
		
		if faces.size() < 2:
			edge_curvatures[edge] = 0
			continue
		
		var f1 := faces[0]
		var f2 := faces[1]
		
		var v1 := mesh_tool.get_vertex(mesh_tool.get_face_vertex(f2, 0))
		var v2 := mesh_tool.get_vertex(mesh_tool.get_face_vertex(f2, 1))
		var v3 := mesh_tool.get_vertex(mesh_tool.get_face_vertex(f2, 2))
		
		var inner := mesh_tool.get_vertex(mesh_tool.get_edge_vertex(edge, 0))
		var outer : Array[Vector3] = [v1, v2, v3]
		outer.erase(mesh_tool.get_vertex(mesh_tool.get_edge_vertex(edge, 0)))
		outer.erase(mesh_tool.get_vertex(mesh_tool.get_edge_vertex(edge, 1)))
		
		var normal := Plane(
				mesh_tool.get_vertex(mesh_tool.get_face_vertex(f1, 0)),
				mesh_tool.get_vertex(mesh_tool.get_face_vertex(f1, 1)),
				mesh_tool.get_vertex(mesh_tool.get_face_vertex(f1, 2))).normal
		
		var a := normal.dot((inner - outer.front()).normalized())
		if a > -0.05 and a < 0.1:
			edge_curvatures[edge] = 0
		elif a > 0:
			edge_curvatures[edge] = 1
		else:
			edge_curvatures[edge] = -1
	return edge_curvatures
