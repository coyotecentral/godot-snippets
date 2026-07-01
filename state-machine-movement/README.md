# CharacterBody2D Movement FSM

A drop-in finite state machine for a Godot 4 `CharacterBody2D`, built around
four core movement states: `Idle`, `Run`, `Jump`, `Fall`.

## Files

- `state.gd` — base `State` class. Every concrete state extends this.
- `state_machine.gd` — the `StateMachine` node that owns states and routes
  transitions.
- `idle_state.gd`, `run_state.gd`, `jump_state.gd`, `fall_state.gd` — the
  four movement states.
- `player_controller.gd` — example `CharacterBody2D` script that wires
  everything together.

## Scene setup

```
Player (CharacterBody2D)  -> player_controller.gd
├── AnimatedSprite2D
└── StateMachine           -> state_machine.gd
    ├── Idle                -> idle_state.gd
    ├── Run                 -> run_state.gd
    ├── Jump                -> jump_state.gd
    └── Fall                -> fall_state.gd
```

Node **names** double as state names — `StateMachine` looks up transition
targets by `name.to_lower()`, so keep the child node names as `Idle`, `Run`,
`Jump`, `Fall` (or add your own and match the string you `transitioned.emit()`
with).

You'll also need two input actions defined in Project Settings > Input Map:
`move_left` / `move_right` (or a single `move_left`/`move_right` axis pair)
and `jump`.

## The null-check behavior

Every state calls `play_animation("name")` instead of touching
`animated_sprite.play()` directly. That helper (in `state.gd`) checks, in
order:

1. Is `animated_sprite` itself null? (e.g. `setup()` was never called)
2. Is `animated_sprite.sprite_frames` null? (no SpriteFrames resource assigned)
3. Does `sprite_frames.has_animation(anim_name)` return false? (animation
   doesn't exist under that name — typo, or the art asset just doesn't
   have a "fall" animation, etc.)

Any of those cause a `push_warning` and an early return instead of a runtime
error, so swapping in placeholder art or an incomplete animation set won't
crash the state machine.

## Extending

To add a state (e.g. `WallSlide`, `Dash`, `Crouch`):

1. Create `wall_slide_state.gd` extending `State`.
2. Implement `enter()`, `physics_update(delta)`, and call
   `transitioned.emit(self, "target_state_name")` wherever you want to leave it.
3. Add it as a child node of `StateMachine` named to match, and register it
   as one of the return-transition targets from whichever states border it.

`character` and `animated_sprite` are already populated on every state by
`StateMachine.setup()`, so new states get them for free.
