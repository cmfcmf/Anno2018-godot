extends Node

var animations = {}
var rotations = null
var current_animation_idx = 0
var current_rotation_idx = 0
var current_repeats = 0

func begin(sprite_frames):
	$animated_sprite.frames = sprite_frames
	animations = sprite_frames.get_meta("animations")
	rotations = sprite_frames.get_meta("rotations")
	play()

func _on_animation_finished():
	var anim_name = $animated_sprite.animation
	var animation = animations[int(anim_name.substr(0, anim_name.find('_')))]
	if animation.has('AnimRept') and current_repeats < animation['AnimRept']:
		current_repeats += 1
		$animated_sprite.play()
		return
	
	if animation['Kind'] == 'RANDOM':
		var next_animation_candidates = animation['AnimNr']
		set_animation(next_animation_candidates[randi() % next_animation_candidates.size()])
	elif animation['Kind'] == 'JUMPTO':
		set_animation(animation['AnimNr'])
	elif animation['Kind'] == 'ENDLESS':
		#if animation['AnimAdd'] == 0:
		#	$animated_sprite.stop()
		#	$animated_sprite.hide()
		pass
	else:
		assert(false)

func set_animation(animation_idx):
	current_animation_idx = animation_idx
	play()

func set_rotation(rotation_idx):
	if rotation_idx < rotations:
		current_rotation_idx = rotation_idx
	else:
		current_rotation_idx = 0
	play()

func play():
	var animation_name = "%s_%s" % [str(current_animation_idx), str(current_rotation_idx)]
	# Make the AnimatedSprite's origin the bottom left corner
	$animated_sprite.offset = Vector2(0, -$animated_sprite.frames.get_frame(animation_name, 0).get_height())
	$animated_sprite.play(animation_name)
	$animated_sprite.show()
