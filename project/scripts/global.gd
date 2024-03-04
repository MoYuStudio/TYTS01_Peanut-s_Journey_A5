
extends Node

func _ready():
	DisplayServer.window_set_title("Peanut's Journey")
	
	Engine.set_max_fps(60)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	DisplayServer.window_set_size(Vector2(1280,720))
	DisplayServer.window_set_position(Vector2(100,200))

func save_data(slot_name,data):
	var file = FileAccess.open('data/'+str(slot_name)+'.moyudata', FileAccess.WRITE)
	var json_str = JSON.stringify(data)
	file.store_line(json_str)
	
func load_data(slot_name):
	var path = 'data/'+str(slot_name)+'.moyudata'
	var data = {}
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var json_str = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		data = json.get_data()
	return data
