extends Control

## Demo of the curvature baker addon.
##
## Provides a way to generate curvature maps of GLTF models and save
## them to disk.

@onready var file_dialog: FileDialog = $FileDialog
@onready var result_texture_rect: TextureRect = $ResultTextureRect
@onready var curvature_baker: CurvatureBaker = $CurvatureBaker
@onready var save_button: Button = %SaveButton
@onready var working_panel: Panel = $WorkingPanel

func _ready() -> void:
	save_button.disabled = true
	working_panel.hide()


## Generate the curvature map of the given GLTF file.
func generate_from_file(path: String):
	working_panel.show()
	var mesh := get_mesh_from_gltf(path)
	result_texture_rect.texture = await curvature_baker.bake_curvature_map(mesh)
	save_button.disabled = false
	working_panel.hide()


## Save the last baked map to the resource file system.
func save_result():
	result_texture_rect.texture.get_image().save_png("res://result.png")


## Load the first mesh from a GLTF file.
func get_mesh_from_gltf(path: String) -> Mesh:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_file(path, state)
	var scene := doc.generate_scene(state)
	return scene.get_child(0).mesh


func _on_choose_mesh_button_pressed() -> void:
	file_dialog.popup_centered_ratio(.5)


func _on_file_dialog_file_selected(path: String) -> void:
	generate_from_file(path)


func _on_save_button_pressed() -> void:
	save_result()
