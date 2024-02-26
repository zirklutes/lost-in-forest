extends TileMap

@onready var player = $"../../CharactersParallaxLayer/Characters"

var cover_scene = preload("res://scenes/game/map/map_tile_cover.tscn")

#var enemy_scene = preload("res://scenes/game/map/map_enemy.tscn")
#var bonus_scene = preload("res://scenes/game/map/map_bonus.tscn")
#var available_options = ['Bonus', 'Bonus', 'Bonus', 'Empty', 'Empty']
#var enemies = ['enemy1', 'enemy2', 'enemy3', 'enemy4', 'enemy5', 'enemy6']

#Tile needs to be unlocked first then near by tiles changes from disabled to locked
# disabled -> locked -> available
enum TILE_STATE { AVAILABLE, LOCKED, DISABLED}
var astar: AStar2D

#Initial data
var player_position: Vector2 = Vector2(0,2)
var available_tiles: Array[Vector2] = [player_position]

var is_moving: bool = false
var map_grid = []
var map_player_position = Vector2(0,2)



func _ready():
	var data = SaveManager.get_save_data('map')
	print('data', data)
	if data:
		map_grid = data['grid']
		map_player_position = data['player_position']
	else:
		map_player_position = player_position
		var size = get_used_rect().size
		for i in size.x:
			map_grid.append([])
			for j in size.y:
				map_grid[i].append(TILE_STATE.DISABLED)
				
	create_astar_map()
	draw_astar_map()
	position_player()
	if !data:
		set_tiles_state()
	cover_unavailable_tiles()
	
func _unhandled_input(event):
	if event is InputEventMouse:
		if event.button_mask == MOUSE_BUTTON_LEFT and event.is_pressed():
			var local_mouse_pos = get_local_mouse_position()
			var cell_coord_mouse_clicked = local_to_map(local_mouse_pos)
			var id = get_astart_cell_id(cell_coord_mouse_clicked)
			
			if id == -1:
				return
			
			if map_grid[cell_coord_mouse_clicked.x][cell_coord_mouse_clicked.y] == TILE_STATE.DISABLED:
				return;
							
			var path = get_astar_path(player.global_position, local_mouse_pos)
			
			if !path.is_empty() and !is_moving:
				is_moving = true
				print('path ', path)
				
				var tile_player_at = local_to_map(path[path.size()-1])
				
				print('tile_player_at ', tile_player_at)
				map_player_position = tile_player_at
				move_player(path)
			
				if map_grid[cell_coord_mouse_clicked.x][cell_coord_mouse_clicked.y] == TILE_STATE.LOCKED:
					map_grid[cell_coord_mouse_clicked.x][cell_coord_mouse_clicked.y] = TILE_STATE.AVAILABLE
					update_neighbour_tiles_state(cell_coord_mouse_clicked)

func create_astar_map():
	var size = get_used_rect().size
	astar = AStar2D.new()
	astar.reserve_space(size.x * size.y)
	
	for i in size.x:
#		grid.append([])
		for j in size.y:
#			grid[i].append(TILE_STATE.DISABLED)
			if get_cell_source_id(0, Vector2i(i,j)) != -1:				
				var cell_id = get_astart_cell_id(Vector2(i,j))
				astar.add_point(cell_id, map_to_local(Vector2(i,j)))
				
				#For DEBUGGING ONLY				
				var tile_center_pos = map_to_local(Vector2(i,j))
				var text_node = Label.new()
				text_node.position = tile_center_pos
				text_node.text = str(cell_id ) + ' ' + str(Vector2(i,j))
				add_child(text_node)


func draw_astar_map():
	var size = get_used_rect().size
		
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
	return -1 #If coords are not valid return not valid id


func set_tiles_state():
	for a_tile in available_tiles:
		map_grid[a_tile.x][a_tile.y] = TILE_STATE.AVAILABLE
		
		update_neighbour_tiles_state(a_tile)


func update_neighbour_tiles_state(pos: Vector2):
	var a_tile_id = get_astart_cell_id(pos)
	var connections = astar.get_point_connections(a_tile_id)

	for c_point in connections:
		var c_point_pos = astar.get_point_position(c_point)
		var c_point_local = local_to_map(c_point_pos)
		
		if map_grid[c_point_local.x][c_point_local.y] != TILE_STATE.AVAILABLE:
			map_grid[c_point_local.x][c_point_local.y] = TILE_STATE.LOCKED
			astar.set_point_disabled(c_point)


func cover_unavailable_tiles():
	var size = map_grid.size()
	
	for x in size:
		var size_y = map_grid[x].size()
		for y in size_y:
			if map_grid[x][y] == TILE_STATE.LOCKED or map_grid[x][y] == TILE_STATE.DISABLED:				
				if get_cell_source_id(0, Vector2i(x,y)) != -1:
					var new_pos = map_to_local(Vector2i(x, y))
					var cover = cover_scene.instantiate()
					
					cover.position =  new_pos
					add_child(cover)
		
	
func get_tile_state(pos: Vector2):
	return map_grid[pos.x][pos.y]

func get_astar_path(start_pos:Vector2, target_pos:Vector2):
	var start_cell_coord = local_to_map(to_local(start_pos))
	var start_cell_id=get_astart_cell_id(start_cell_coord)

	var target_cell_coord = local_to_map(target_pos)
	var target_cell_id=get_astart_cell_id(target_cell_coord) #Maybe add id validation inside id creation function
	
	if astar.has_point(start_cell_id) and astar.has_point(target_cell_id):
		astar.set_point_disabled(target_cell_id, false)
		var path =  astar.get_point_path(start_cell_id, target_cell_id)

		return path
	return []

func position_player():
	#TODO in the future tile coords should be saved in game save file
	var initial_id = get_astart_cell_id(map_player_position)
	var tile_player_at = astar.get_point_position(initial_id)
	
	player.global_position = to_global(tile_player_at)


func move_player(positions: Array):
	var target_position = to_global(positions[0])	
	var tween = create_tween()
	
	tween.tween_property(player, 'global_position', target_position, 1)
	await tween.finished
	positions.pop_front()
	
	if positions.is_empty():
		is_moving = false
		update_save()
		return
		
	move_player(positions)

func update_save(): 
	var map = {
		'grid': map_grid,
		'player_position': map_player_position
	}
	SaveManager.set_save_data('map', map)
