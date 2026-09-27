extends CanvasLayer


# ============================================================
# HUD REFERENCES
# ============================================================

@onready var ui: Control = $UI
@onready var evolution_label: Label = $UI/EvolutionLabel


# ============================================================
# PLAYER REFERENCE
# ============================================================

var player: CharacterBody2D = null


# ============================================================
# HUD STATE
# ============================================================

var current_points: int = 0
var banked_points: int = 0
var mate_nearby: bool = false


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Force UI into viewport space.
	ui.position = Vector2.ZERO
	ui.size = get_viewport().get_visible_rect().size

	evolution_label.position = Vector2(
		20.0,
		20.0
	)

	evolution_label.size = Vector2(
		500.0,
		160.0
	)


	# --------------------------------------------------------
	# FIND PLAYER
	# --------------------------------------------------------

	player = get_tree().get_first_node_in_group(
		"player"
	) as CharacterBody2D

	if player == null:

		push_warning(
			"HUD could not find the Player."
		)

		return


	# --------------------------------------------------------
	# CONNECT PLAYER SIGNALS
	# --------------------------------------------------------

	player.evolution_points_changed.connect(
		_on_evolution_points_changed
	)

	player.mate_range_changed.connect(
		_on_mate_range_changed
	)


	# --------------------------------------------------------
	# INITIAL DISPLAY
	# --------------------------------------------------------

	current_points = player.evolution_points
	banked_points = player.banked_evolution_points

	update_hud()


# ============================================================
# EVOLUTION POINT UPDATE
# ============================================================

func _on_evolution_points_changed(
	new_current_points: int,
	new_banked_points: int
) -> void:

	current_points = new_current_points
	banked_points = new_banked_points

	update_hud()


# ============================================================
# MATE RANGE UPDATE
# ============================================================

func _on_mate_range_changed(
	in_range: bool
) -> void:

	mate_nearby = in_range

	update_hud()


# ============================================================
# DRAW HUD
# ============================================================

func update_hud() -> void:

	var hud_text: String = (
		"Evolution Points: "
		+ str(current_points)
		+ "\nBanked: "
		+ str(banked_points)
	)


	if mate_nearby:

		hud_text += (
			"\n\nCompatible Mate Nearby"
			+ "\nPress R to Reproduce"
		)


	evolution_label.text = hud_text
