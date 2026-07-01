## Optional state — only reachable when character.can_double_jump is true
## (see the "Double Jump" export group in character_controller.gd).
extends State

func enter() -> void:
	play_animation("double_jump")
	if character:
		character.velocity.y = character.double_jump_velocity
		character.has_double_jumped = true

func physics_update(delta: float) -> void:
	if character == null:
		return

	character.apply_gravity(delta)

	if character.can_dash and character.can_start_dash() and Input.is_action_just_pressed("dash"):
		transitioned.emit(self, "dash")
		return

	var direction := character.get_input_direction()
	character.velocity.x = direction * character.speed
	if animated_sprite and direction != 0.0:
		animated_sprite.flip_h = direction < 0.0

	character.move_and_slide()

	if character.velocity.y >= 0.0:
		transitioned.emit(self, "fall")
