extends Node

var b_id = null
var b_gfx = null
var b_kind = null
var b_size = Vector2(0, 0)
var b_rotate = null
var b_anim_add = null
var b_can_be_built = false

var b_position = Vector2(0, 0)

var config = null
var rauch_animations = []

func init(config, rauch_animations):
	self.config = config
	self.rauch_animations = rauch_animations

func located_at(tile_pos):
	return b_position.x <= tile_pos.x and tile_pos.x < b_position.x + b_size.x and \
		   b_position.y <= tile_pos.y and tile_pos.y < b_position.y + b_size.y

func draw_field(map, pos, rotation, animation_step):
	var sx = b_size.x if rotation % 2 == 0 else b_size.y
	var sy = b_size.y if rotation % 2 == 0 else b_size.x
	for y in range(sy):
		for x in range(sx):
			map.set_cellv(pos + Vector2(x, y), get_tile_id(x, y, rotation, animation_step))
			
	for rauch_animation_name in rauch_animations.keys():
		var rauch_animation = rauch_animations[rauch_animation_name]
		
		# TODO: The next lines are very much a work in progress and still 
		# not fully correct. Here's the current status
		# - The flag animation for towers is positioned correctly.
		# - Animations for square buildings in default rotation have 
		#   the correct x value, but are too low
		# - Animations for rectangular buildings in default rotation
		#   have both incorrect x and y values
		
		# TODO: If we were to use Posoffs, the coast towers' flags are 
		# offset, because they use the same animation as the land towers.
		var top_pos = map.map_to_world(pos) + Vector2(0, 200) + Vector2(0, -20) #+ Vector2(0, -config['Posoffs'])
		
		
		var bottom_pos = top_pos + \
						 b_size.x * Vector2(map.cell_size.x / 2.0, map.cell_size.y / 2.0) + \
						 b_size.y * Vector2(-map.cell_size.x / 2.0, map.cell_size.y / 2.0) + \
						 Vector2(0, 0)
						
		var fahn_pos = bottom_pos + \
					   Vector2(map.cell_size.x / 2.0, -map.cell_size.y / 2.0) * rauch_animation['Fahnoffs'][0] + \
					   Vector2(-map.cell_size.x / 2.0, -map.cell_size.y / 2.0) * rauch_animation['Fahnoffs'][1] + \
					   Vector2(0, -map.cell_size.y) * rauch_animation['Fahnoffs'][2] + \
					   Vector2(0, 0)
		
		# TODO: This is currently not used.
		var fahne_pos_off = fahn_pos + \
							Vector2(rauch_animation['Posoffs'][0], -rauch_animation['Posoffs'][1]) + \
							Vector2(0, 0)
		
		var animated_sprite = AnimatedSprite.new()
		var frames = load("res://imported/animations/%s_0.res" % rauch_animation_name)
		animated_sprite.frames = frames
		animated_sprite.playing = true
		animated_sprite.offset = Vector2(0, -200)
		animated_sprite.centered = false
		# This effectively positions the sprite's center bottom on fahn_pos
		animated_sprite.position = fahn_pos + \
								   Vector2(
										-frames.get_frame('default', 0).get_width() / 2, 
										-frames.get_frame('default', 0).get_height()) + \
								   Vector2(0, 0)
								
		if rauch_animation_name.begins_with('RAUCH'):
			animated_sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.5)
		map.add_child(animated_sprite)
		
		#add_debug_marker(0, map, top_pos)
		#add_debug_marker(1, map, bottom_pos)
		#add_debug_marker(2, map, fahn_pos)
		#add_debug_marker(3, map, fahne_pos_off)


func add_debug_marker(id, map, pos):
	var debug_marker = Sprite.new()
	var image = Image.new()
	assert(image.load("res://tmp/marker.png") == OK)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	debug_marker.texture = texture
	debug_marker.centered = true
	debug_marker.offset = Vector2(0, -200)
	debug_marker.position = pos
	debug_marker.self_modulate = Color(id * 0.1, 0.0, (10 - id) * 0.1, 1.0)
	map.add_child(debug_marker)
	

func get_tile_id(x, y, rotation, animation_step):
	var tile_id = 1 + b_gfx
	if b_rotate > 0:
		tile_id += rotation * b_size.x * b_size.y # Rotate?
	tile_id += animation_step * b_anim_add
	
	if rotation == 0:
		tile_id += y * b_size.x + x
	elif rotation == 1:
		tile_id += b_size.x * b_size.y - 1 - (x * b_size.x + (b_size.x - 1 - y))
	elif rotation == 2:
		tile_id += (b_size.y - 1 - y) * b_size.x + (b_size.x - 1 - x)
	elif rotation == 3:
		tile_id += x * b_size.x + (b_size.x - 1 - y)
	else:
		assert(false)
	return tile_id
