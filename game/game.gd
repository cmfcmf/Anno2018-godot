extends Node2D

func _ready():
	var game = $save_game_loader.load_game("res://imported/saves/game00.gam")
	
	var building_fields = get_field_dict($fields/buildings.get_children())
	var land_fields = get_field_dict($fields/land.get_children())
	
	for island in game['islands']:
		print(island['num'])
		print(island['width'])
		print(island['height'])
		print(island['x'])
		print(island['y'])
		for y in range(island['height']):
			for x in range(island['width']):
				var field = island['fields'][x][y]
				var field_id = field['building']
				
				if land_fields.has(field_id):
					land_fields[field_id].draw_field($map/buildings, Vector2(island['x'] + x, island['y'] + y), field['rotation'])
				if building_fields.has(field_id):
					building_fields[field_id].build($map/buildings, Vector2(island['x'] + x, island['y'] + y), field['rotation'])

func get_field_dict(scenes):
	var dict = {}
	for scene in scenes:
		dict[scene.b_id] = scene
	return dict	