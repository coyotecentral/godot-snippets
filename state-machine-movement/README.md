# CharacterBody2D Movement FSM

A drop-in finite state machine for a Godot 4 `CharacterBody2D`, built around
four core movement states — `Idle`, `Run`, `Jump`, `Fall` — plus two optional
ones, `DoubleJump` and `Dash`, toggled on/off via exported properties.

## Files

- `state.gd` — base `State` class. Every concrete state extends this.
- `state_machine.gd` — the `StateMachine` node that owns states and routes
  transitions.
- `idle_state.gd`, `run_state.gd`, `jump_state.gd`, `fall_state.gd` — the
  four core movement states.
- `double_jump_state.gd` — optional second mid-air jump.
- `dash_state.gd` — optional fixed-speed horizontal dash.
- `character_controller.gd` — example `CharacterBody2D` script (`class_name
  CharacterController`) that wires everything together and exposes the
  toggles for the two optional states.

## Scene setup

```
Player (CharacterBody2D)  -> character_controller.gd
├── AnimatedSprite2D
└── StateMachine           -> state_machine.gd
    ├── Idle                -> idle_state.gd
    ├── Run                 -> run_state.gd
    ├── Jump                -> jump_state.gd
    ├── Fall                -> fall_state.gd
    ├── DoubleJump          -> double_jump_state.gd   (optional)
    └── Dash                -> dash_state.gd          (optional)
```

Node **names** double as state names — `StateMachine` looks up transition
targets by `name.to_lower()`, so keep the child node names as `Idle`, `Run`,
`Jump`, `Fall`, `DoubleJump`, `Dash` (or add your own and match the string
you `transitioned.emit()` with, e.g. `"double_jump"` and `"dash"`).

You'll also need input actions defined in Project Settings > Input Map:
`move_left` / `move_right`, `jump`, and — only if you're using dash —
`dash`.

## Optional states: DoubleJump and Dash

Both new states are gated by exported properties on `character_controller.gd`
rather than by whether their node exists in the scene, so you can leave
`DoubleJump`/`Dash` nodes in the tree and just flip a checkbox in the
Inspector to turn them on or off per-character:

- **`can_double_jump` (bool, default off)** — when true, pressing `jump`
  again while airborne (from `Jump` or `Fall`) triggers `double_jump_velocity`
  once. The charge resets the moment the character lands — `Idle`/`Run`
  call `character.reset_double_jump()` on `enter()`.
- **`can_dash` (bool, default off)**, with `dash_speed`, `dash_duration`,
  `dash_cooldown` — when true, pressing `dash` from any grounded or airborne
  state locks in the current input direction (or facing direction if no
  input is held) and moves at a flat `dash_speed` for `dash_duration`
  seconds, ignoring gravity. `dash_cooldown` gates re-triggering via
  `character.can_start_dash()`, checked in every state before transitioning.

If a toggle is left `false`, the corresponding transition check in each
state simply never fires — no need to remove the child node from the scene.
Conversely, if you flip a toggle on without adding the matching state node,
`StateMachine` will `push_warning` and stay in the current state rather
than erroring.

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
