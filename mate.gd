extends Area2D


# ============================================================
# MATE
# ============================================================
#
# Compatible member of the player's current lineage.
#
# Each mate can reproduce once. After successful reproduction,
# the mate is removed from the world.
# ============================================================


# ============================================================
# EVOLUTION STATE
# ============================================================

var has_jaws: bool = false
var has_paired_fins: bool = false


# ============================================================
# ORIENTATION
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

	fish_body.apply_evolution(
		has_jaws,
		has_paired_fins
	)

	fish_body.set_orientation(
		starting_direction.normalized(),
		max_pitch_degrees
	)


# ============================================================
# PLAYER ENTERS RANGE
# ============================================================

func _on_reproduction_area_body_entered(body: Node2D) -> void:

	if not body.is_in_group("player"):
		return

	if has_reproduced:
		return

	player_in_range = true
	nearby_player = body as CharacterBody2D

	if nearby_player.has_method("set_nearby_mate"):
		nearby_player.set_nearby_mate(self)

	print("Compatible mate found!")


# ============================================================
# PLAYER LEAVES RANGE
# ============================================================

func _on_reproduction_area_body_exited(body: Node2D) -> void:

	if body != nearby_player:
		return

	if nearby_player != null:

		if nearby_player.has_method("clear_nearby_mate"):
			nearby_player.clear_nearby_mate(self)

	player_in_range = false
	nearby_player = null

	print("Compatible mate out of range.")


# ============================================================
# REPRODUCTION QUERY
# ============================================================

func can_reproduce_with(player: CharacterBody2D) -> bool:

	return (
		not has_reproduced
		and player_in_range
		and nearby_player == player
	)


# ============================================================
# REPRODUCTION
# ============================================================

func on_reproduction(player: CharacterBody2D) -> void:

	if not can_reproduce_with(player):
		return


	# --------------------------------------------------------
	# MARK THIS MATE AS USED
	# --------------------------------------------------------

	has_reproduced = true
	player_in_range = false


	# --------------------------------------------------------
	# CLEAR PLAYER'S MATE REFERENCE
	# --------------------------------------------------------

	# This also tells the HUD that there is no longer a
	# compatible mate nearby.

	if player.has_method("clear_nearby_mate"):
		player.clear_nearby_mate(self)


	nearby_player = null


	# --------------------------------------------------------
	# DESPAWN
	# --------------------------------------------------------

	print("Reproduction successful. Mate despawning.")

	queue_free()
