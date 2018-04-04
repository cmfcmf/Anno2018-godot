extends ItemList

signal building_selected

func _ready():
	for building in get_tree().get_nodes_in_group("buildings"):
		var texture = ImageTexture.new()
		var image = Image.new()
		if image.load("res://imported/tools/" + str(building.b_gfx_menu) + ".png") != OK:
			print("Error loading image :(")
		texture.create_from_image(image)
		
		add_item(building.b_name, texture)
		set_item_metadata(get_item_count() - 1, {
			'building': building
		})

func _on_menu_build_buildings_item_selected(index):
	unselect(index)
	
	var metadata = get_item_metadata(index)
	var building = metadata['building']
	emit_signal("building_selected", building)
