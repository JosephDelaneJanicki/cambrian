extends Area2D


# ============================================================
# MATE
# ============================================================
#
# Represents another compatible member of the player's
# current lineage.
#
# FishBody handles the mate's appearance.
# Mate handles reproduction-related behavior.
# ============================================================


# ============================================================
# SIGNALS
# ============================================================

signal player_entered_reproduction_range(mate: Area2D)
signal player_left_reproduction_range(mate: Area2D)


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


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Give this mate the current lineage appearance.
	fish_body.apply_evolution(
		has_jaws,
		has_paired_fins
	)

	# Use the exact same visual orientation system as Player.
	fish_body.set_orientation(
		starting_direction.normalized(),
		max_pitch_degrees
	)


# ============================================================
# PLAYER ENTERS REPRODUCTION RANGE
# ============================================================

func _on_reproduction_area_body_entered(body: Node2D) -> void:

	if not body.is_in_group("player"):
		return

	player_in_range = true
	nearby_player = body as CharacterBody2D

	print("Compatible mate found!")

	player_entered_reproduction_range.emit(self)


# ============================================================
# PLAYER LEAVES REPRODUCTION RANGE
# ============================================================

func _on_reproduction_area_body_exited(body: Node2D) -> void:

	if body != nearby_player:
		return

	player_in_range = false
	nearby_player = null

	print("Compatible mate out of range.")

	player_left_reproduction_range.emit(self)


# ============================================================
# REPRODUCTION QUERY
# ============================================================

func can_reproduce_with(player: CharacterBody2D) -> bool:

	return (
		player_in_range
		and nearby_player == player
	)
