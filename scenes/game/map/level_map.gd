extends Node2D

var enemy_scene = preload("res://scenes/game/map/map_enemy.tscn")
var bonus_scene = preload("res://scenes/game/map/map_bonus.tscn")

var available_options = ['Bonus', 'Bonus', 'Bonus', 'Empty', 'Empty']
var enemies = ['enemy1', 'enemy2', 'enemy3', 'enemy4', 'enemy5', 'enemy6']


func _ready():
	pass
#	var tiles = $Tiles.get_children().filter(func(obj): return obj.type != 'Start')
#	print(enemies.size())
#	for enemy in enemies:
#		var selected_tile = tiles[randi()%len(tiles)]
#		var enemy_item = enemy_scene.instantiate()
#		selected_tile.type = 'Enemey'
#		selected_tile.add_child(enemy_item)
#		tiles.erase(selected_tile)
#
#	for tile in tiles:
#		var type = available_options[randi()%len(available_options)]
#		tile.type = type
#		if type == 'Bonus':
#			var bonus = bonus_scene.instantiate()
#			tile.add_child(bonus)

#func _input(event):
#	if event is InputEventMouseMotion:
#		$ParallaxBackground/MapParallax.motion_offset += event.relative * 0.05
