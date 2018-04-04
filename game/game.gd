extends Node2D

func _ready():
#	var sheep_farm = preload("res://imported/buildings/2664/2664.tscn").instance()
#	sheep_farm.init()
#	sheep_farm.build($map/buildings, Vector2(30, 30))
#	
#	var cathedral = preload("res://imported/buildings/4992/4992.tscn").instance()
#	cathedral.init()
#	cathedral.build($map/buildings, Vector2(20, 20))
#	
#	var market = preload("res://imported/buildings/4700/4700.tscn").instance()
#	market.init()
#	market.build($map/buildings, Vector2(10, 40))

	var game = $save_game_loader.load_game("res://imported/saves/game00.gam")
	for island in game['islands']:
		print(island['num'])
		print(island['width'])
		print(island['height'])
		print(island['x'])
		print(island['y'])
		for y in range(island['height']):
			for x in range(island['width']):
				var field = island['fields'][y][x]
				var field_id = field['building']
				for land in $fields/land.get_children():
					if land.b_id == field_id:
						land.draw_field($map/land, Vector2(island['x'] + x, island['y'] + y))
						break
				
				for building in $fields/buildings.get_children():
					if building.b_id == field_id:
						building.build($map/buildings, Vector2(island['x'] + x, island['y'] + y))
						break