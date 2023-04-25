extends SubViewport

## [SubViewport] which renders a set of smooth colored lines using a shader.

@onready var _background_rect : ColorRect = $BackgroundRect

## Render the given lines and return the [ViewportTexture].
func render_lines(lines : PackedVector2Array, colors : PackedColorArray,
		result_size : Vector2, thickness := 0.02,
		background_color := Color.WHITE) -> Texture:
	size = result_size
	_background_rect.color = background_color
	_background_rect.size = result_size
	
	for line in range(0, lines.size(), 2):
		var line_rect := ColorRect.new()
		line_rect.size = result_size
		var material := ShaderMaterial.new()
		material.shader = preload("line.gdshader")
		material.set_shader_parameter("a", lines[line])
		material.set_shader_parameter("b", lines[line + 1])
		material.set_shader_parameter("col", colors[line / 2.0])
		material.set_shader_parameter("size", thickness)
		line_rect.material = material
		add_child(line_rect)
	
	render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	
	for line in range(1, get_child_count()):
		get_child(line).queue_free()
	
	return get_texture()
