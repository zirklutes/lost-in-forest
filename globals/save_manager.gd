extends Node

const SAVEPATH = "user://data.tres"
var savedata : SaveData

func _init():
	_load_game()

func _load_game():
	if ResourceLoader.exists(SAVEPATH):
		savedata = load(SAVEPATH)
	else:
		new_game()

func new_game():
	savedata = SaveData.new()
	save_game()

func set_save_data(id, data):
	print('DATA TO SAVE ', data)
	savedata.data[id] = data
	save_game()

func get_save_data(id, optional = null):
	if savedata.data.get(id):
		return savedata.data[id]
	return optional
	
func save_game():
	ResourceSaver.save(savedata, SAVEPATH)
