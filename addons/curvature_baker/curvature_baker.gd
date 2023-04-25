class_name CurvatureBaker
extends Node

## Utility for baking grayscale curvature maps from a mesh.

@onready var _line_renderer : SubViewport = $LineRenderer

const _CurvatureUtils = preload("curvature_utils.gd")
const _MeshUtils = preload("mesh_utils.gd")

## The returned texture is a [ViewportTexture], so it has will change
## on further calls to [method bake_curvature_map]. Create a copy to
## avoid this:
## [br]
## [codeblock]
##     var texture := ImageTexture.create_from_image(result.get_image()
## [/codeblock]
func bake_curvature_map(mesh : Mesh, result_size := Vector2(1024, 1024),
		surface := 0) -> Texture:
	var mesh_tool := MeshDataTool.new()
	var join_data : Dictionary = _MeshUtils.join_duplicates(mesh, surface)
	mesh_tool.create_from_surface(join_data.mesh, 0)
	var edge_curvatures = _CurvatureUtils.get_edge_curvatures(mesh_tool)
	var lines : PackedVector2Array = []
	var colors : PackedColorArray = []
	
	var old_mesh_tool := MeshDataTool.new()
	old_mesh_tool.create_from_surface(mesh, surface)
	for edge in mesh_tool.get_edge_count():
		var curvature : float = edge_curvatures[edge]
		if curvature == 0:
			continue
		var a := mesh_tool.get_edge_vertex(edge, 0)
		var b := mesh_tool.get_edge_vertex(edge, 1)
		for a_id in join_data.original_ids[a]:
			for a_edge in old_mesh_tool.get_vertex_edges(a_id):
				var egde_verts := [
					old_mesh_tool.get_edge_vertex(a_edge, 0),
					old_mesh_tool.get_edge_vertex(a_edge, 1),
				]
				for other_id in join_data.original_ids[b]:
					if other_id in egde_verts:
						lines.append(old_mesh_tool.get_vertex_uv(a_id))
						lines.append(old_mesh_tool.get_vertex_uv(other_id))
						colors.append(_grayscale((curvature + 1) / 2.0))
	
	var result = await _line_renderer.render_lines(lines, colors, result_size,
			_MeshUtils.get_texel_density(mesh) / 500.0, _grayscale(.5))
	return result


func _grayscale(value : float) -> Color:
	return Color().from_hsv(0, 0, value)
