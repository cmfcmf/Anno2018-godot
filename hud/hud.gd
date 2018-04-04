extends CanvasLayer

signal building_selected

func _on_building_selected(building):
	emit_signal("building_selected", building)
