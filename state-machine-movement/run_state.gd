extends State

func enter() -> void:
	play_animation("run")

func physics_update(delta: float) -> void:
	if character == null:
		return

	character.apply_gravity(delta)

	if not character.is_on_floor():
		transitioned.emit(self, "fall")
		return

	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jump")
		return

	var direction := character.get_input_direction()
	if direction == 0.0:
		transitioned.emit(self, "idle")
		return

	character.velocity.x = direction * character.speed
	if animated_sprite:
		animated_sprite.flip_h = direction < 0.0

	character.move_and_slide()
