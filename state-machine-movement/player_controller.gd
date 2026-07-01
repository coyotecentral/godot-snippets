## Example CharacterBody2D that drives itself via a child StateMachine.
## Scene layout expected:
##   Player (CharacterBody2D, this script)
##   ├── AnimatedSprite2D
##   └── StateMachine
##       ├── Idle  (IdleState)
##       ├── Run   (RunState)
##       ├── Jump  (JumpState)
##       └── Fall  (FallState)
extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	state_machine.setup(self, animated_sprite)

func get_input_direction() -> float:
	return Input.get_axis("move_left", "move_right")

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
