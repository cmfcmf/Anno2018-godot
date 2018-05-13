extends Node2D

# Data
var ship_rotation
var ship_info

# Nodes
var ship_sprite
var bug_animation

func begin(ship_name, animation_data, new_rotation = 0):
	ship_info = animation_data[ship_name]

	ship_rotation = new_rotation
	
	ship_sprite = Sprite.new()
	ship_sprite.centered = false
	
	bug_animation = preload("res://entities/animation.tscn").instance()
	bug_animation.begin(load("user://imported/animations/%s.tres" % ship_info['Bugfignr']))
	
	_change_rotation()
	
	self.add_child(bug_animation)
	self.add_child(ship_sprite)
	
	$DEBUG.draw_origin(self, $DEBUG.C_GREEN)
	$DEBUG.draw_origin(bug_animation)
	$DEBUG.draw_origin(ship_sprite)
	$DEBUG.draw_sprite_outline(ship_sprite)
	
	$DEBUG.draw_animated_sprite_outline(bug_animation.find_node("animated_sprite"), $DEBUG.C_YELLOW)

func set_ship_rotation(new_rotation):
	ship_rotation = new_rotation
	_change_rotation()

func _change_rotation():
	var cell_size = game_data.CELL_SIZE
	
	ship_sprite.texture = load("user://imported/SHIP/%s.res" % (ship_info['Gfx'] + ship_rotation + 1))
	ship_sprite.transform = Transform2D(
		0.0, 
		Vector2(
			-ship_sprite.texture.get_width() / 2, # + ship_info['Posoffs'][0], 
			-ship_sprite.texture.get_height() -ship_info['Posoffs'][1]
		)
	)
	bug_animation.set_rotation(ship_rotation)
	bug_animation.transform = Transform2D(0.0, Vector2(
		0.0,
		-ship_info['Posoffs'][1]
	))
	
	$DEBUG.draw_point(bug_animation.position + Vector2(0, -cell_size.y * ship_info['Fahnoffs'][2] + ship_info['Posoffs'][1]), $DEBUG.C_GREEN)
