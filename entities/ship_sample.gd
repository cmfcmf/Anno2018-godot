extends Control

var ship = null
var figure_data = null

func _ready():
	figure_data = game_data.get_animation_data()
	for figure_name in figure_data.keys():
		var figure = figure_data[figure_name]
		if figure.has('Bugfignr'):
			$s_type.add_item(figure_name)
	
	_change_ship()

func _change_ship():
	if ship != null:
		$ship_area.remove_child(ship)
	
	ship = preload("res://entities/ship/ship.tscn").instance()
	ship.begin($s_type.get_item_text($s_type.selected), figure_data, $s_rotation.value)
	$ship_area.add_child(ship)

func _on_s_type_item_selected(ID):
	_change_ship()

func _on_s_rotation_value_changed(new_rotation):
	ship.set_ship_rotation(new_rotation)
