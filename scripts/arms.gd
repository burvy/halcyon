extends Node3D

@export var raycast: RayCast3D
@export var range: float = 100.0

func _ready() -> void:
	raycast.target_position = Vector3(0.0, 0.0, -range)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("click"):
		handle_held_click()


# HELPER FUNCTIONS

func handle_held_click() -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		print("Hit object", raycast.get_collider())
