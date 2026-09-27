extends Node


# ============================================================
# LINEAGE MANAGER
# ============================================================
#
# Persistent state belonging to the lineage rather than any
# individual organism.
# ============================================================


# ============================================================
# GENERATION
# ============================================================

var generation: int = 1


# ============================================================
# EVOLUTION POINTS
# ============================================================

var banked_evolution_points: int = 0


# ============================================================
# EVOLUTION COSTS
# ============================================================

const JAWS_COST: int = 30
const PAIRED_FINS_COST: int = 20
const IMPROVED_TAIL_COST: int = 30
const SENSORY_ORGANS_COST: int = 20
const DERMAL_ARMOR_COST: int = 40


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
		"Lineage checkpoint updated. Banked EP: ",
		banked_evolution_points,
		" | Position: ",
		checkpoint_position
	)


# ============================================================
# SPEND EP
# ============================================================

func can_afford(cost: int) -> bool:

	return banked_evolution_points >= cost


func spend_points(cost: int) -> bool:

	if not can_afford(cost):
		return false

	banked_evolution_points -= cost

	return true


# ============================================================
# PURCHASE EVOLUTIONS
# ============================================================

func purchase_jaws() -> bool:

	if has_jaws:
		return false

	if not spend_points(JAWS_COST):
		return false

	has_jaws = true
	return true


func purchase_paired_fins() -> bool:

	if has_paired_fins:
		return false

	if not spend_points(PAIRED_FINS_COST):
		return false

	has_paired_fins = true
	return true


func purchase_improved_tail() -> bool:

	if has_improved_tail:
		return false

	if not spend_points(IMPROVED_TAIL_COST):
		return false

	has_improved_tail = true
	return true


func purchase_sensory_organs() -> bool:

	if has_sensory_organs:
		return false

	if not spend_points(SENSORY_ORGANS_COST):
		return false

	has_sensory_organs = true
	return true


func purchase_dermal_armor() -> bool:

	if has_dermal_armor:
		return false

	if not spend_points(DERMAL_ARMOR_COST):
		return false

	has_dermal_armor = true
	return true


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
# EVOLUTION STATE
# ============================================================

func get_evolution_state() -> Dictionary:

	return {
		"jaws": has_jaws,
		"paired_fins": has_paired_fins,
		"improved_tail": has_improved_tail,
		"sensory_organs": has_sensory_organs,
		"dermal_armor": has_dermal_armor
	}
