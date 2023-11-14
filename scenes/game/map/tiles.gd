extends TileMap

var astar: AStar2D
var astar_path_points: Array[Vector2]
var tile_size = tile_set.tile_size
var initial_tile_id = 2

var is_moving: bool = false

#Tile needs to be unlocked first then near by tiles changes from disabled to locked
enum TILE_STATE { LOCKED, DISABLED}


@onready var player = $"../../CharactersParallaxLayer/Characters"

func _ready():
#	get_tree().get_root().size_changed.connect(center_map)
#	center_map()
	draw_astar_map()
	position_player()
	

func _input(event):
	if event is InputEventMouse:
		if event.button_mask == MOUSE_BUTTON_LEFT and event.is_pressed():
			var local_mouse_pos = get_local_mouse_position()		
			var path = get_astar_path(player.global_position, local_mouse_pos)
			
			if !path.is_empty() and !is_moving:
				move_player(path)

func center_map():
	var widthInTiles = get_used_rect().size[0]

	var widthInPixels = widthInTiles*tile_size[0]*scale[0]
	var heightInTiles = get_used_rect().size[1]
	var tiles_count = ((heightInTiles-1)/2)*1.5 + 1
	var heightInPixels = tile_size[1]*tiles_count*scale[1]

	var viewportSize = get_viewport_rect().size
	var viewportWidth = viewportSize[0]
	var viewportHeight = viewportSize[1]

	position.x = (viewportWidth-widthInPixels)/2
	position.y = (viewportHeight-heightInPixels)/2

func draw_astar_map():
	var size = get_used_rect().size
	astar = AStar2D.new()
	astar.reserve_space(size.x * size.y)
	
	for i in size.x:
		for j in size.y:
			if get_cell_source_id(0, Vector2i(i,j)) != -1:
				var cell_id = get_astart_cell_id(Vector2(i,j))
				astar.add_point(cell_id, map_to_local(Vector2(i,j)))
				
				var tile_center_pos = map_to_local(Vector2(i,j))
				var text_node = Label.new()
				text_node.position = tile_center_pos
				text_node.text = str(cell_id ) + ' ' + str(Vector2(i,j))
				add_child(text_node)
	
	for i in size.x:
		for j in size.y:
			if get_cell_source_id(0, Vector2i(i,j)) != -1:
				var cell_id = get_astart_cell_id(Vector2(i,j))
				var neighbour_cells = []
					
				if j % 2 == 0:
					neighbour_cells = [
						Vector2(i-1, j),
						Vector2(i+1, j), 
						Vector2(i-1, j-1),
						Vector2(i, j-1),
						Vector2(i-1, j+1), 
						Vector2(i, j+1)
					]
				else:
					neighbour_cells = [
						Vector2(i-1, j),
						Vector2(i+1, j), 
						Vector2(i, j-1),
						Vector2(i+1, j-1),
						Vector2(i, j+1), 
						Vector2(i+1, j+1)
					]
					
				for neighbour_cell in neighbour_cells:
					var neighbour_id = get_astart_cell_id(neighbour_cell)
					
					if astar.has_point(neighbour_id):
						astar.connect_points(cell_id, neighbour_id, true)	


func get_astart_cell_id(cell_coord:Vector2):
	var size = get_used_rect().size
	if cell_coord.x >= 0 and cell_coord.x < size.x and cell_coord.y >= 0 and cell_coord.y < size.y:
		return int(cell_coord.y + cell_coord.x * get_used_rect().size.y)
	return -1 #If coords are not valid return none existant id


func get_astar_path(start_pos:Vector2, target_pos:Vector2)->Array:
	var start_cell_coord = local_to_map(to_local(start_pos))
	var start_cell_id=get_astart_cell_id(start_cell_coord)

	var target_cell_coord = local_to_map(target_pos)
	var target_cell_id=get_astart_cell_id(target_cell_coord) #Maybe add id validation inside id creation function
	
	
#	print('start_pos ', start_pos)
#	print('local ', to_local(start_pos))
#	print('start_cell_coord ', start_cell_coord)
#	print('start_cell_id ', start_cell_id)
	print('target_cell_coord ', target_cell_coord)
	print('target_cell_id ', target_cell_id)
#	print('Target connections  ', astar.get_point_connections(target_cell_id))
#	print('PATH IDS: ', astar.get_id_path(start_cell_id, target_cell_id))
	#A small check to see if both points are in the grid
	if astar.has_point(start_cell_id) and astar.has_point(target_cell_id):
		var path =  astar.get_point_path(start_cell_id, target_cell_id)
#		path.remove_at(0)
		return path
	
	return []

func position_player():
	#TODO in the future tile id should be saved in game save file
	var tile_player_at = astar.get_point_position(initial_tile_id)
	
	player.global_position = to_global(tile_player_at)

func move_player(positions: Array):
	is_moving = true
	var target_position = to_global(positions[0])	
	var tween = create_tween()
	
	tween.tween_property(player, 'global_position', target_position, 1)
	await tween.finished
	positions.pop_front()
	
	if positions.is_empty():
		is_moving = false
		return
		
	move_player(positions)
