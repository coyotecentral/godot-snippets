## Optional state — only reachable when character.can_start_dash() is true
## (see the "Dash" export group in character_controller.gd). Dash ignores
## gravity and locks in its direction for the full duration.
extends State

var _time_remaining: float = 0.0
var _direction: float = 1.0

func enter() -> void:
	play_animation("dash")
	if character == null:
		return

	_time_remaining = character.dash_duration
	_direction = character.get_input_direction()
	if _direction == 0.0:
		_direction = character.get_facing_direction()

	character.velocity.y = 0.0
	character.velocity.x = _direction * character.dash_speed
	character.start_dash_cooldown()

func physics_update(delta: float) -> void:
	if character == null:
		return

	_time_remaining -= delta

	# Gravity is intentionally skipped — a dash holds a flat trajectory.
	character.velocity.x = _direction * character.dash_speed
	character.velocity.y = 0.0

	character.move_and_slide()

	if _time_remaining <= 0.0:
		if character.is_on_floor():
			if character.get_input_direction() == 0.0:
				transitioned.emit(self, "idle")
			else:
				transitioned.emit(self, "run")
		else:
			transitioned.emit(self, "fall")
