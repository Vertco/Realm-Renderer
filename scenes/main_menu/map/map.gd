extends Control

@warning_ignore("unused_signal")
signal pressed(path:String)
@warning_ignore("unused_signal")
signal double_pressed(path:String)
@warning_ignore("unused_signal")
signal show_in_file_manager(path:String)
@warning_ignore("unused_signal")
signal map_selected(path:String)
@warning_ignore("unused_signal")
signal delete(path:String)

@export_global_dir() var path:String
var selected:bool:
	set(value):
		selected = value
		if selected:
			set_self_modulate(Color(1,1,1))
		else:
			if hover:
				set_self_modulate(Color(1,1,1,0.5))
			else:
				set_self_modulate(Color(1,1,1,0))
var hover:bool = false

func _ready() -> void:
	var folder = path.get_file()
	%PopupMenu.id_pressed.connect(popup_menu)
	%Name.text = folder
	tooltip_text = folder
	# TODO Add image preview
	#var map:ZIPReader = ZIPReader.new()
	#map.open(path)
	#if map.file_exists("thumbnail.webp"):
		#var image:Image = Image.new()
		#var texture:ImageTexture = ImageTexture.new()
		#var image_data:PackedByteArray = map.read_file("thumbnail.webp")
		#var error:Error = image.load_webp_from_buffer(image_data)
		#if error == OK:
			#texture.create_from_image(image)
			#%PreviewImage.texture = texture
	#map.close()


func _on_mouse_entered() -> void:
	hover = true
	self_modulate = Color(1,1,1,0.5)


func _on_mouse_exited() -> void:
	hover = false
	if selected:
		self_modulate = Color(1,1,1)
	else:
		set_self_modulate(Color(1,1,1,0))


func popup_menu(id:int) -> void:
	match id:
		0:
			emit_signal("show_in_file_manager",path.get_base_dir())
		1:
			emit_signal("delete",path)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				emit_signal("double_pressed",path)
			elif event.pressed:
				selected = true
				emit_signal("pressed",path)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			%PopupMenu.position = get_global_mouse_position()
			%PopupMenu.visible = true
