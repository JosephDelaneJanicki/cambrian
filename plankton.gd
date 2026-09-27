extends Area2D


# ============================================================
# PLANKTON
# ============================================================

@export var evolution_value: int = 1


# ============================================================
# DRIFT
# ============================================================

# Slow movement through the water.
@export var min_drift_speed: float = 4.0
@export var max_drift_speed: float = 12.0

# How quickly the plankton's drift direction changes.
@export var direction_change_speed: float = 0.5

# Current movement direction.
var drift_direction: Vector2 = Vector2.ZERO

# Direction we're gradually drifting toward.
var target_direction: Vector2 = Vector2.ZERO

var drift_speed: float = 0.0


func _ready() -> void:

	# Give every plankton a slightly different speed.
	drift_speed = randf_range(
		min_drift_speed,
		max_drift_speed
	)

	# Start each plankton moving in a random direction.
	var random_angle: float = randf_range(
		0.0,
		TAU
	)

	drift_direction = Vector2.RIGHT.rotated(random_angle)

	choose_new_target_direction()


func _process(delta: float) -> void:

	# Gradually steer toward the target direction.
	drift_direction = drift_direction.lerp(
		target_direction,
		direction_change_speed * delta
	).normalized()

	# Apply the gentle drift.
	position += drift_direction * drift_speed * delta

	# Occasionally choose another direction.
	if randf() < 0.15 * delta:
		choose_new_target_direction()


# ============================================================
# RANDOM DRIFT DIRECTION
# ============================================================

func choose_new_target_direction() -> void:

	var random_angle: float = randf_range(
		0.0,
		TAU
	)

	target_direction = Vector2.RIGHT.rotated(random_angle)


# ============================================================
# CONSUMPTION
# ============================================================

func consume() -> int:

	var value: int = evolution_value

	queue_free()

	return value
