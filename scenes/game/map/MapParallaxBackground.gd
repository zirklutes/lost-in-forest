extends ParallaxBackground


var viewport_size
var relative_x
var relative_y

func _ready():
	get_tree().get_root().size_changed.connect(viewport_changed) # register event if viewport changes
	viewport_changed()
	relative_x = 0
	relative_y = 0

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_x = event.position.x
		var mouse_y = event.position.y
		
#		Map the mouse coordinates on the screen between the intervall [-1 1].
		relative_x = -1 * (mouse_x - (viewport_size.x/2)) / (viewport_size.x/2)
		relative_y = -1 * (mouse_y - (viewport_size.y/2)) / (viewport_size.y/2)
		# print("relative_y: " + str(relative_y))
		# print("relative_x: " + str(relative_x))
		var count = 4
		for child in self.get_children(): # for each parallaxlayer do...
			child.motion_offset.x = count * relative_x
			child.motion_offset.y = count * relative_y
			count = count * 1.6

# gets called on the start of the application once and every time the viewport changes
# centers the images
func viewport_changed():
	viewport_size = get_viewport().size
#	for child in self.get_children():
#		child.get_node("Sprite").offset = Vector2(viewport_size.x / 2, viewport_size.y / 2)

