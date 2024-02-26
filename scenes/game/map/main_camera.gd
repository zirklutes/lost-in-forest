class_name ZoomingCamera2D
extends Camera2D

# Lower cap for the `_zoom_level`.
@export var min_zoom := 0.8
# Upper cap for the `_zoom_level`.
@export var max_zoom := 2.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
@export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
@export var zoom_duration := 0.2


# The camera's target zoom level.
var _zoom_level := 1.0 : 
	set = _set_zoom_level

	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			print(event.relative)
			print('zoom', zoom)
			position -= event.relative *  1.5
	elif event.is_action_pressed("zoom_in"):
		_set_zoom_level(_zoom_level - zoom_factor)
	elif event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)
		

func _set_zoom_level(value: float) -> void:	
	_zoom_level = clamp(value, min_zoom, max_zoom)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self,"zoom",Vector2(_zoom_level, _zoom_level), zoom_duration).set_ease(Tween.EASE_OUT)



