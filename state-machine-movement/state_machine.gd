## Generic finite state machine for a CharacterBody2D's movement.
## Add State-derived nodes as children (their node names ARE the state
## names, e.g. "Idle", "Run", "Jump", "Fall") and set initial_state.
extends Node
class_name StateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.transitioned.connect(_on_state_transitioned)

	if initial_state == null and get_child_count() > 0:
		initial_state = get_child(0) as State

	if initial_state:
		current_state = initial_state
		current_state.enter()
	else:
		push_warning("StateMachine '%s' has no states to enter." % name)

## Call this from the owning CharacterBody2D after it wires up
## character/animated_sprite references on each state (see
## player_controller.gd for the expected pattern).
func setup(character: CharacterBody2D, animated_sprite: AnimatedSprite2D) -> void:
	for state in states.values():
		state.character = character
		state.animated_sprite = animated_sprite

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _on_state_transitioned(_from_state: State, new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name.to_lower())

	if new_state == null:
		push_warning("StateMachine '%s': no state named '%s'" % [name, new_state_name])
		return

	if new_state == current_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
