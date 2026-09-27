extends Area2D


# ============================================================
# MATE
# ============================================================

@export var starting_direction: Vector2 = Vector2.LEFT
@export_range(0.0, 89.0) var max_pitch_degrees: float = 80.0


# ============================================================
# NODE REFERENCES
# ============================================================

@onready var fish_body: Node2D = $FishBody
@onready var reproduction_area: Area2D = $ReproductionArea


# ============================================================
# REPRODUCTION STATE
# ============================================================

var player_in_range: bool = false
var nearby_player: CharacterBody2D = null
var has_reproduced: bool = false


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# All compatible mates represent the same current lineage.
	fish_body.apply_evolution(
		LineageManager.has_jaws,
		LineageManager.has_paired_fins,
		LineageManager.has_improved_tail,
		LineageManager.has_sensory_organs,
		LineageManager.has_dermal_armor
	)
	
	choose_new_wander_direction()

	fish_body.set_orientation(
		starting_direction.normalized(),
		max_pitch_degrees
	)

# ============================================================
# WANDERING
# ============================================================

@export var wander_speed: float = 45.0
@export var direction_change_min: float = 1.5
@export var direction_change_max: float = 4.0

var wander_direction: Vector2 = Vector2.RIGHT
var direction_timer: float = 0.0

# ============================================================
# PLAYER ENTERS RANGE
# ============================================================

func _on_reproduction_area_body_entered(
	body: Node2D
) -> void:

	if not body.is_in_group("player"):
		return


	if has_reproduced:
		return


	player_in_range = true

	nearby_player = body as CharacterBody2D


	if nearby_player.has_method(
		"set_nearby_mate"
	):

		nearby_player.set_nearby_mate(
			self
		)


	print(
		"Compatible mate found!"
	)


# ============================================================
# PLAYER LEAVES RANGE
# ============================================================

func _on_reproduction_area_body_exited(
	body: Node2D
) -> void:

	if body != nearby_player:
		return


	if nearby_player != null:

		if nearby_player.has_method(
			"clear_nearby_mate"
		):

			nearby_player.clear_nearby_mate(
				self
			)


	player_in_range = false
	nearby_player = null


	print(
		"Compatible mate out of range."
	)


# ============================================================
# REPRODUCTION QUERY
# ============================================================

func can_reproduce_with(
	player: CharacterBody2D
) -> bool:

	return (
		not has_reproduced
		and player_in_range
		and nearby_player == player
	)


# ============================================================
# REPRODUCTION
# ============================================================

func on_reproduction(
	player: CharacterBody2D
) -> void:

	if not can_reproduce_with(player):
		return


	has_reproduced = true
	player_in_range = false


	if player.has_method(
		"clear_nearby_mate"
	):

		player.clear_nearby_mate(
			self
		)


	nearby_player = null


	print(
		"Reproduction successful. ",
		"Mate despawning."
	)


	# Mate is consumed after successful reproduction.
	queue_free()


# ============================================================
# WANDERING
# ============================================================

func _process(delta: float) -> void:

	direction_timer -= delta


	if direction_timer <= 0.0:

		choose_new_wander_direction()


	position += (
		wander_direction
		* wander_speed
		* delta
	)


	fish_body.set_orientation(
		wander_direction,
		max_pitch_degrees
	)


# ============================================================
# CHOOSE WANDER DIRECTION
# ============================================================

func choose_new_wander_direction() -> void:

	wander_direction = Vector2.RIGHT.rotated(
		randf_range(
			0.0,
			TAU
		)
	)


	direction_timer = randf_range(
		direction_change_min,
		direction_change_max
	)
