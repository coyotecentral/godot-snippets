extends State

func enter() -> void:
	play_animation("idle")
	if character:
		character.velocity.x = 0.0
		character.reset_double_jump()

func physics_update(delta: float) -> void:
	if character == null:
		return

	character.apply_gravity(delta)

	if character.can_dash and character.can_start_dash() and Input.is_action_just_pressed("dash"):
		transitioned.emit(self, "dash")
		return

	if not character.is_on_floor():
		transitioned.emit(self, "fall")
		return

	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return

	var direction := character.get_input_direction()
	if direction != 0.0:
		transitioned.emit(self, "run")
		return

	character.move_and_slide()
