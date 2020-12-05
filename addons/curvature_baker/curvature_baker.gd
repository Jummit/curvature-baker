extends Node

onready var line_renderer : Viewport = $LineRenderer

const CurvatureUtils := preload("curvature_utils.gd")
const MeshUtils := preload("mesh_utils.gd")

func bake_curvature_map(mesh : Mesh, line_thickness := 0.03, surface := 0) -> ImageTexture:
	var mesh_tool := MeshDataTool.new()
	var join_data := MeshUtils.join_duplicates(mesh)
	mesh_tool.create_from_surface(join_data.mesh, surface)
	var edge_curvatures = CurvatureUtils.get_edge_curvatures(mesh_tool)
	var lines : PoolVector2Array = []
	var colors : PoolColorArray = []
	
	var old_mesh_tool := MeshDataTool.new()
	old_mesh_tool.create_from_surface(mesh, surface)
	for edge in mesh_tool.get_edge_count():
		var curvature : float = edge_curvatures[edge]
		if curvature == 0:
			continue
		var a := mesh_tool.get_edge_vertex(edge, 0)
		var b := mesh_tool.get_edge_vertex(edge, 1)
		for v in join_data.original_ids[a]:
			for e in old_mesh_tool.get_vertex_edges(v):
				var egde_verts := [
					old_mesh_tool.get_edge_vertex(e, 0),
					old_mesh_tool.get_edge_vertex(e, 1),
				]
				for ov in join_data.original_ids[b]:
					if ov in egde_verts:
						lines.append(old_mesh_tool.get_vertex_uv(v))
						lines.append(old_mesh_tool.get_vertex_uv(ov))
						colors.append(_grayscale((curvature + 1) / 2.0))
	
	var result = line_renderer.render_lines(lines, colors, Vector2(1024, 1024),
			line_thickness, _grayscale(.5))
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	return result


func _grayscale(value : float) -> Color:
	return Color().from_hsv(0, 0, value)
