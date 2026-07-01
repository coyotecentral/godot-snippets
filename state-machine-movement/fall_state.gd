extends State

func enter() -> void:
	play_animation("fall")

func physics_update(delta: float) -> void:
	if character == null:
		return

	character.apply_gravity(delta)

	if character.can_dash and character.can_start_dash() and Input.is_action_just_pressed("dash"):
		transitioned.emit(self, "dash")
		return

	if character.can_double_jump and not character.has_double_jumped and Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "double_jump")
		return

	var direction := character.get_input_direction()
	character.velocity.x = direction * character.speed
	if animated_sprite and direction != 0.0:
		animated_sprite.flip_h = direction < 0.0

	character.move_and_slide()

	if character.is_on_floor():
		if direction == 0.0:
			transitioned.emit(self, "idle")
		else:
			transitioned.emit(self, "run")
