extends Control


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map/level_map.tscn")
	
