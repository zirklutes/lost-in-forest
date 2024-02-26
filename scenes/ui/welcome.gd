extends Control

var manager = preload("res://globals/save_manager.gd")


func _on_play_button_pressed():
	SaveManager.new_game()
	get_tree().change_scene_to_file("res://scenes/game/map/level_map.tscn")

func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game/map/level_map.tscn")



