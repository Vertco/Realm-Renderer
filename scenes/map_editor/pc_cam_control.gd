extends Control

const margin:Dictionary = {
	"top": 35.0,
	"right": 5.0,
	"bottom": 5.0,
	"left": 5.0
}
const seperation:float = 5
const preview_size:Vector2 = Vector2(256,35)

var dragging:bool
var offscreen:bool
var show_preview:bool = true

func update() -> void:
	if get_viewport():
		# Calculate scaled size and position
		var pc_size:Vector2 = Vector2(%PcWindow.get_visible_rect().size)
		var rect_pos:Vector2 = (%PcCamera.get_offset()*%GmCamera.zoom)+((Vector2(get_viewport().get_size()) / 2) - ((pc_size/%PcCamera.zoom / 2) * %GmCamera.zoom)) - %GmCamera.get_offset() * %GmCamera.zoom
		var rect_size:Vector2 = pc_size/%PcCamera.zoom * %GmCamera.zoom
		
		# Set view rect
		%PcView.set_position(rect_pos)
		%PcView.set_size(rect_size)
		
		# Set initial header position
		%PcViewHeader.set_position(rect_pos)
		var header_width:float = get_on_screen_size(%PcView).x-(margin.left+margin.right)
		%PcViewHeader.set_size(Vector2(header_width,%PcViewHeader.size.y))
		
		# Set initial preview position
		%PcPreview.set_position(rect_pos)
		
		# Calculate and apply header offset
		var header_offset:Vector2 = Vector2(rect_size.x/2-%PcViewHeader.size.x/2,-%PcViewHeader.size.y-seperation)
		var offset_pos:Vector2
		%PcPreview.set_size(Vector2(preview_size.x,preview_size.x/pc_size.aspect()))
		if %PcPreview.visible:
			offset_pos = (rect_pos + header_offset).clamp(Vector2(margin.left,margin.top), Vector2(get_viewport().get_size())-(Vector2(margin.right,clamp(%PcPreview.size.y+seperation+margin.bottom,0,get_viewport().get_size().y-seperation-%PcViewHeader.size.y))+%PcViewHeader.size))
		else:
			offset_pos = (rect_pos + header_offset).clamp(Vector2(margin.left,margin.top), Vector2(get_viewport().get_size())-(Vector2(margin.right,margin.bottom)+%PcViewHeader.size))
		%PcViewHeader.set_position(offset_pos)
		
		# Calculate and apply preview offset
		var preview_offset:Vector2 = Vector2(rect_size.x/2-%PcPreview.size.x/2,0)
		var preview_offset_pos:Vector2 = (rect_pos + preview_offset).clamp(Vector2(seperation,margin.top+margin.bottom+%PcViewHeader.size.y), Vector2(get_viewport().get_size())-(Vector2(5,5)+%PcPreview.size))
		%PcPreview.set_position(preview_offset_pos)
		
		# Show or hide the preview depending on if the view is offscreen
		if offscreen && %PcWindow.visible && show_preview:
			%PcPreview.show()
		else:
			%PcPreview.hide()
		
		# Update scaling
		%PcSettings.update_pc_zoom(Vector2(Preferences.pc_view_size_x,Preferences.pc_view_size_y))


func get_on_screen_size(node:Node) -> Vector2:
	# Get the global rectangle of the node
	var global_rect = node.get_global_rect()
	var viewport_size = get_viewport().get_visible_rect()
	
	# Calculate the intersection of the node's rectangle and the viewport rectangle
	var intersection = global_rect.intersection(viewport_size)
	
	if intersection.size == Vector2(0,0):
		offscreen = true
	else:
		offscreen = false
		show_preview = true
	
	# Return the size of the intersection rectangle
	return intersection.size


func _on_pc_view_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if event.double_click:
				%GmCamera.set_offset(%PcCamera.offset)
				%GmGridRenderer.queue_redraw()
				update()
	elif event is InputEventMouseMotion:
		if dragging:
			%PcCamera.set_offset(%PcCamera.offset+(event.relative/%GmCamera.zoom))
			update()
			%PcGridRenderer.queue_redraw()


func _on_hide_preview_btn_pressed() -> void:
	show_preview = false
	%PcPreview.hide()
	update()


func _on_pc_view_btn_pressed() -> void:
	%PcOverlay.visible = !%PcOverlay.visible
	if %PcOverlay.visible:
		%PcViewBTN.icon = preload("res://media/icons/pc_view.svg")
		%PcViewBTN.tooltip_text = "Reveal"
	else:
		%PcViewBTN.icon = preload("res://media/icons/pc_view_hidden.svg")
		%PcViewBTN.tooltip_text = "Cover"


func _on_pc_settings_btn_pressed() -> void:
	%PcSettings.popup_centered()


func _on_pc_overlay_visibility_changed() -> void:
	%PcCamControlOverlay.visible = %PcOverlay.visible
	if %PcOverlay.visible:
		%PcViewBTN.icon = preload("res://media/icons/pc_view.svg")
	else:
		%PcViewBTN.icon = preload("res://media/icons/pc_view_hidden.svg")
