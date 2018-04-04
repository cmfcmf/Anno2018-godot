extends Node2D

func _on_start_game_btn_pressed():
	get_tree().change_scene("res://game/game.tscn")

func _on_load_files_btn_pressed():
	$load_files_dialog.popup_centered_ratio(0.75)

func _on_load_files_dialog_dir_selected(dir):
	var required_files = [
		"1602.exe",
		"figuren.cod",
		"haeuser.cod",
		"GFX/STADTFLD.BSH",
		"ToolGfx/TOOLS.BSH",
	]
	
	var anno_dir = Directory.new()
	anno_dir.open(dir)
	
	for file in required_files:
		if not anno_dir.file_exists(file):
			$warning_dialog.set_text("Missing file: " + file)
			$warning_dialog.popup_centered()
			return
	
	$parsers.parse(dir)