extends Camera2D

const speed = 2000
const zoom_speed = 0.1

func _ready():
	set_process_input(true)

func _process(delta):
	var movement = Vector2(0, 0)
	if Input.is_action_pressed("camera_up"):
		movement += Vector2(0, -1)
	if Input.is_action_pressed("camera_down"):
		movement += Vector2(0, +1)
	if Input.is_action_pressed("camera_left"):
		movement += Vector2(-1, 0)
	if Input.is_action_pressed("camera_right"):
		movement += Vector2(+1, 0)
	
	offset += movement.normalized() * speed * delta

func _input(event):
	if event.is_action("camera_zoom_in"):
		zoom += Vector2(1, 1).normalized() * zoom_speed
	elif event.is_action("camera_zoom_out"):
		zoom -= Vector2(1, 1).normalized() * zoom_speed
