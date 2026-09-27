extends Node


# ============================================================
# LINEAGE MANAGER
# ============================================================
#
# Persistent state belonging to the lineage rather than to
# any individual organism.
#
# Individual Player instances can die and be replaced.
# This node survives those deaths.
# ============================================================


# ============================================================
# GENERATION
# ============================================================

var generation: int = 1


# ============================================================
# EVOLUTION POINTS
# ============================================================

# EP successfully preserved through reproduction.
var banked_evolution_points: int = 0


# ============================================================
# EVOLUTION TRAITS
# ============================================================

var has_jaws: bool = false
var has_paired_fins: bool = false
var has_improved_tail: bool = false
var has_sensory_organs: bool = false
var has_dermal_armor: bool = false


# ============================================================
# REPRODUCTION CHECKPOINT
# ============================================================

var has_checkpoint: bool = false
var checkpoint_position: Vector2 = Vector2.ZERO


# ============================================================
# BANK PROGRESS
# ============================================================

func bank_progress(
	points: int,
	position: Vector2
) -> void:

	banked_evolution_points = points

	checkpoint_position = position
	has_checkpoint = true

	print(
		"Lineage checkpoint updated. ",
		"Banked EP: ",
		banked_evolution_points,
		" | Position: ",
		checkpoint_position
	)


# ============================================================
# BEGIN NEXT GENERATION
# ============================================================

func begin_next_generation() -> void:

	generation += 1

	print(
		"Beginning generation ",
		generation
	)


# ============================================================
# EVOLUTION QUERIES
# ============================================================

func get_evolution_state() -> Dictionary:

	return {
		"jaws": has_jaws,
		"paired_fins": has_paired_fins,
		"improved_tail": has_improved_tail,
		"sensory_organs": has_sensory_organs,
		"dermal_armor": has_dermal_armor
	}


# ============================================================
# DEBUG
# ============================================================

func print_lineage_state() -> void:

	print(
		"Generation: ",
		generation
	)

	print(
		"Banked EP: ",
		banked_evolution_points
	)

	print(
		"Checkpoint: ",
		checkpoint_position
	)

	print(
		"Jaws: ",
		has_jaws
	)

	print(
		"Paired Fins: ",
		has_paired_fins
	)

	print(
		"Improved Tail: ",
		has_improved_tail
	)

	print(
		"Sensory Organs: ",
		has_sensory_organs
	)

	print(
		"Dermal Armor: ",
		has_dermal_armor
	)
