## Example CharacterBody2D that drives itself via a child StateMachine.
## Scene layout expected:
##   Player (CharacterBody2D, this script: character_controller.gd)
##   ├── AnimatedSprite2D
##   └── StateMachine
##       ├── Idle        (idle_state.gd)
##       ├── Run          (run_state.gd)
##       ├── Jump          (jump_state.gd)
##       ├── Fall           (fall_state.gd)
##       ├── DoubleJump  (double_jump_state.gd)  -- optional, see can_double_jump below
##       └── Dash           (dash_state.gd)      -- optional, see can_dash below
##
## DoubleJump and Dash nodes can stay in the scene even when their toggle is
## off below — the states never get transitioned into unless the matching
## export is enabled, so leaving them in place costs nothing.
extends CharacterBody2D
class_name CharacterController

@export_group("Movement")
@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 900.0

@export_group("Double Jump")
## Turn on to allow a second mid-air jump. Requires a "DoubleJump" state
## node in the StateMachine (see DoubleJumpState/double_jump_state.gd).
@export var can_double_jump: bool = false
@export var double_jump_velocity: float = -350.0

@export_group("Dash")
## Turn on to allow a horizontal dash. Requires a "Dash" state node in the
## StateMachine (see DashState/dash_state.gd) and a "dash" input action.
@export var can_dash: bool = false
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

## True once the extra mid-air jump has been used; reset when grounded.
var has_double_jumped: bool = false

var _dash_cooldown_remaining: float = 0.0

func _ready() -> void:
	state_machine.setup(self, animated_sprite)

func _physics_process(delta: float) -> void:
	if _dash_cooldown_remaining > 0.0:
		_dash_cooldown_remaining -= delta

func get_input_direction() -> float:
	return Input.get_axis("move_left", "move_right")

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

## Facing direction as ±1, based on the sprite's current flip state.
## Dash uses this as a fallback when there's no directional input held.
func get_facing_direction() -> float:
	if animated_sprite and animated_sprite.flip_h:
		return -1.0
	return 1.0

func reset_double_jump() -> void:
	has_double_jumped = false

## Whether a dash can be started right now (toggle on + off cooldown).
## States should check this before transitioning to "dash".
func can_start_dash() -> bool:
	return can_dash and _dash_cooldown_remaining <= 0.0

func start_dash_cooldown() -> void:
	_dash_cooldown_remaining = dash_cooldown
