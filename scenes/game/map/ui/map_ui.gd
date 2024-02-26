extends CanvasLayer

@onready var pause_menu_scene = $PauseMenu
var paused = false

func _process(_delta):
	if Input.is_action_just_pressed("pause_menu"):
		pause_menu()

func pause_menu():
	if paused:
		get_tree().paused = false
		pause_menu_scene.hide()
	else:
		pause_menu_scene.show()
		get_tree().paused = true
	paused = !paused
	

func _on_main_menu_button_pressed():
	pause_menu()


func _on_quit_game_pressed():
	get_tree().quit()


func _on_close_menu_button_pressed():
	pause_menu()


func _on_save_and_leave_pressed():
	SaveManager.save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/welcome.tscn")


func _on_save_pressed():
	SaveManager.save_game()
