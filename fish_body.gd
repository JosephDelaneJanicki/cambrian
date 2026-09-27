extends Node2D


# ============================================================
# FISH BODY
# ============================================================
#
# Shared visual representation of the species.
#
# BodyPivot controls BOTH:
# - horizontal facing
# - vertical pitch
#
# This means every anatomical evolution placed under
# BodyPivot automatically follows the fish orientation.
# ============================================================


# ============================================================
# NODE REFERENCES
# ============================================================

@onready var body_pivot: Node2D = $BodyPivot

@onready var sprite: Sprite2D = (
	$BodyPivot/Sprite2D
)

@onready var jaw_visual: Sprite2D = (
	$BodyPivot/JawVisual
)
@onready var fins_visual: Sprite2D = (
	$BodyPivot/FinsVisual
)
@onready var tail_visual: Sprite2D = (
	$BodyPivot/TailVisual
)
# ============================================================
# EVOLUTION STATE
# ============================================================

var has_jaws: bool = false
var has_paired_fins: bool = false
var has_improved_tail: bool = false
var has_sensory_organs: bool = false
var has_dermal_armor: bool = false


# ============================================================
# FACING STATE
# ============================================================

# Canonical artwork faces RIGHT.
var facing_left: bool = false


# ============================================================
# ORIENTATION
# ============================================================

func set_orientation(
	direction: Vector2,
	max_pitch_degrees: float = 80.0
) -> void:

	if direction == Vector2.ZERO:
		return


	# --------------------------------------------------------
	# DETERMINE LEFT / RIGHT
	# --------------------------------------------------------

	if direction.x < -0.05:

		facing_left = true

	elif direction.x > 0.05:

		facing_left = false


	# --------------------------------------------------------
	# CALCULATE PITCH
	# --------------------------------------------------------

	var pitch: float = atan2(
		direction.y,
		abs(direction.x)
	)


	var max_pitch: float = deg_to_rad(
		max_pitch_degrees
	)


	pitch = clamp(
		pitch,
		-max_pitch,
		max_pitch
	)


	# --------------------------------------------------------
	# HORIZONTAL FACING
	# --------------------------------------------------------


	if facing_left:

		body_pivot.scale.x = -abs(
			body_pivot.scale.x
		)

	else:

		body_pivot.scale.x = abs(
			body_pivot.scale.x
		)


	# --------------------------------------------------------
	# PITCH
	# --------------------------------------------------------


	if facing_left:

		body_pivot.rotation = -pitch

	else:

		body_pivot.rotation = pitch


# ============================================================
# QUERY FACING
# ============================================================

func is_facing_left() -> bool:

	return facing_left


# ============================================================
# APPLY EVOLUTION
# ============================================================

func apply_evolution(
	jaws: bool,
	paired_fins: bool,
	improved_tail: bool = false,
	sensory_organs: bool = false,
	dermal_armor: bool = false
) -> void:

	has_jaws = jaws
	has_paired_fins = paired_fins
	has_improved_tail = improved_tail
	has_sensory_organs = sensory_organs
	has_dermal_armor = dermal_armor


	update_evolution_visuals()


# ============================================================
# EVOLUTION VISUALS
# ============================================================

func update_evolution_visuals() -> void:

	jaw_visual.visible = has_jaws
	
	fins_visual.visible = has_paired_fins
	
	tail_visual.visible = has_improved_tail
