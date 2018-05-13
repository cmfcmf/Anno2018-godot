extends Control

const FILE_EXTENSION = ".tres"

func _ready():
	var animation_dir = Directory.new()
	assert(OK == animation_dir.open("user://imported/animations"))
	animation_dir.list_dir_begin(true)
	while true:
		var filename = animation_dir.get_next()
		if filename == "":
			break
		assert(filename.ends_with(FILE_EXTENSION))
		
		$t_name.add_item(filename)

func _on_Button_pressed():
	$animation1.begin(load("user://imported/animations/%s" % $t_name.get_item_text($t_name.selected)))
	$animation1.set_animation(int($t_animation.text))
	$animation1.set_rotation(int($t_rotation.text))
	
	$animation2.begin(load("user://imported/animations/SCHATTENLANG.tres"))
	$animation2.set_animation(int($t_animation.text))
	$animation2.set_rotation(int($t_rotation.text))