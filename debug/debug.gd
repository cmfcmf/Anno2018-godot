extends Node2D

const COLOR = Color(1.0, 0.0, 0.0, 1.0)
const C_YELLOW = Color(1.0, 1.0, 0.0)
const C_GREEN = Color(0.0, 1.0, 0.0)

var positions = []
var rects = []

func _draw():
	for position in positions:
		draw_circle(position['pos'], 2, position['color'])
	for rect in rects:
		draw_rect(rect['rect'], rect['color'], false)

func draw_sprite_outline(sprite, color = COLOR):
	rects.append({
		'rect': Rect2(sprite.global_position, sprite.texture.get_size()), 
		'color': color
	})
	rects.append({
		'rect': Rect2(sprite.global_position + sprite.offset, sprite.texture.get_size()), 
		'color': color
	})
	update()
	
	print(sprite.texture.get_size())

func draw_animated_sprite_outline(animated_sprite, color = COLOR):
	rects.append({
		'rect': Rect2(animated_sprite.global_position, animated_sprite.frames.get_frame(animated_sprite.animation, 0).get_size()),
		'color': color,
	})
	rects.append({
		'rect': Rect2(animated_sprite.global_position + animated_sprite.offset, animated_sprite.frames.get_frame(animated_sprite.animation, 0).get_size()),
		'color': color,
	})
	update()
	
func draw_origin(node, color = COLOR):
	draw_point(node.global_position, color)

func draw_point(pos, color = COLOR):
	positions.append({
		'pos': pos,
		'color': color
	})
	update()