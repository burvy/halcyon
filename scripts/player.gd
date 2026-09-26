extends CharacterBody3D


@export var move_speed: float = 5.0
@export var jump_speed: float = 4.5
@export var sprint_multiplier: float = 1.5

@export var camera_sensitivity: float = 0.01

@export var head: Node3D
@export var eyes: Camera3D

## logic to run on game start
func _ready() -> void:
	# locks the mouse when the game starts
	lock_mouse()
	# prevents players from simulating everyone else
	handle_multiplayer_ownership(is_multiplayer_authority())

## `_input`, but it only runs after normal `_input` to allow
## it to cancel out input here. Useful to disallow mouse look
## in menus or something
func _unhandled_input(event: InputEvent) -> void:
	# move things here
	if event.is_action_pressed("ui_cancel"):
		free_mouse()
	if event is InputEventMouseButton:
		lock_mouse()
	if event is InputEventMouseMotion and mouse_is_captured():
		handle_look(event)

## per physics-tick logic
func _physics_process(delta: float) -> void:

	var grounded: bool = is_on_floor()

	handle_gravity(delta, grounded)
	handle_jump(Input.is_action_pressed("jump"), grounded)
	handle_motion(
		Input.is_action_pressed("sprint"),
		grounded,
		Input.get_vector("west", "east", "north", "south")
	)

	move_and_slide()

# HELPER FUNCTIONS

# Multiplayer - START

func handle_multiplayer_ownership(owns_this: bool) -> void:
	if owns_this:
		eyes.current = true
	else:
		set_physics_process(false)
		set_process_unhandled_input(false)

# Multiplayer - END

# ---

# Mouse Locking - START

## locks the mouse
func lock_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## frees the mouse
func free_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func mouse_is_captured() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

# Mouse Locking - END

# ---

# Camera Logic - START

## adds accumulated look motion to the player's head
func handle_look(mouse_motion: InputEventMouseMotion) -> void:
		# rotate body left and right
		rotate_y(-mouse_motion.relative.x * camera_sensitivity)
		# rotate head up and down
		head.rotate_x(-mouse_motion.relative.y * camera_sensitivity)
		# dont allow rotation past 90 degrees
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

# Camera Logic - END

# ---

# Player Motion - START

## accelerates players downwards
## the equation **v = at + u*,
## equivalently, **v += at**
## the player does not accelerate downwards if they are
## already grounded.
func handle_gravity(delta: float, grounded: bool) -> void:
	if not grounded:
		velocity += get_gravity() * delta

## makes players jump
## if the player is jumping and is grounded, they get + `jump_speed`
## applied to the y component of their velocity
func handle_jump(jumping: bool, grounded: bool) -> void:
	if jumping and grounded:
		velocity.y = jump_speed

## applies motion
## if the player is not grounded, they cannot move.
## if the player is not trying to move, do not move.
## if the player is sprinting, apply `sprint_multiplier` to their `move_speed`.
## otherwise, they will move at the normal `move_speed`
func handle_motion(sprinting: bool, grounded: bool, desire: Vector2) -> void:
	# skip movement if not touching the ground
	if not grounded:
		return

	# skip calculation if not moving
	if not desire:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	# adds the desire vector onto where the player is already facing
	var direction: Vector3 = (transform.basis * Vector3(desire.x, 0, desire.y))

	# determines the player's speed based on if they are sprinting
	var move = (move_speed * sprint_multiplier) if sprinting else move_speed

	# multiplies the direction vector by speed,
	# adding that to player velocity
	velocity.x = direction.x * move
	velocity.z = direction.z * move

# Player Motion - END
