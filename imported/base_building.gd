extends "base.gd"

var b_name = null
var b_gfx_bau = null
var b_gfx_menu = null

func build(map, pos, rotation):
	b_position = pos
	
	remove_from_group("buildings")
	map.add_child(self)
	add_to_group("map.buildings")
	
	draw_field(map, pos, rotation)

func clicked():
	print("Building " + b_name + " was clicked!")