extends State

func enter() -> void:
	play_animation("jump")
	if character:
		character.velocity.y = character.jump_velocity

func physics_update(delta: float) -> void:
	if character == null:
		return

	character.apply_gravity(delta)

	var direction := character.get_input_direction()
	character.velocity.x = direction * character.speed
	if animated_sprite and direction != 0.0:
		animated_sprite.flip_h = direction < 0.0

	character.move_and_slide()

	if character.velocity.y >= 0.0:
		transitioned.emit(self, "fall")
