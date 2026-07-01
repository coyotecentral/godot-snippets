## Base class for a single state in the movement FSM.
## Extend this for each concrete state (Idle, Run, Jump, Fall, etc).
extends Node
class_name State

## Emitted when this state wants the machine to switch to another one.
## new_state_name should match the child node's `name` (case-insensitive).
signal transitioned(state: State, new_state_name: String)

var state_machine: StateMachine
var character: CharacterBody2D
var animated_sprite: AnimatedSprite2D

## Called once when the state becomes active.
func enter() -> void:
	pass

## Called once when the state is exited.
func exit() -> void:
	pass

## Called on unhandled input while this state is active.
func handle_input(_event: InputEvent) -> void:
	pass

## Called every physics frame while this state is active.
func physics_update(_delta: float) -> void:
	pass

## Safely plays an animation by name. Every state routes through this
## instead of calling animated_sprite.play() directly, so a missing node
## or a missing/renamed animation never throws — it just warns.
func play_animation(anim_name: String) -> void:
	if animated_sprite == null:
		push_warning("State '%s': animated_sprite is null, cannot play '%s'" % [name, anim_name])
		return

	if animated_sprite.sprite_frames == null:
		push_warning("State '%s': sprite_frames is null, cannot play '%s'" % [name, anim_name])
		return

	if not animated_sprite.sprite_frames.has_animation(anim_name):
		push_warning("State '%s': animation '%s' not found on sprite_frames" % [name, anim_name])
		return

	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)
