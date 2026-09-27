extends CanvasLayer


# ============================================================
# HUD REFERENCES
# ============================================================

@onready var ui: Control = $UI
@onready var evolution_label: Label = $UI/EvolutionLabel


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# --------------------------------------------------------
	# FORCE HUD INTO SCREEN SPACE
	# --------------------------------------------------------

	ui.position = Vector2.ZERO
	ui.size = get_viewport().get_visible_rect().size

	evolution_label.position = Vector2(20.0, 20.0)
	evolution_label.size = Vector2(350.0, 120.0)


	# --------------------------------------------------------
	# FIND PLAYER
	# --------------------------------------------------------

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("HUD could not find the Player.")
		return


	# --------------------------------------------------------
	# CONNECT EP SIGNAL
	# --------------------------------------------------------

	player.evolution_points_changed.connect(
		_on_evolution_points_changed
	)


	# Display starting values immediately.
	_on_evolution_points_changed(
		player.evolution_points,
		player.banked_evolution_points
	)


# ============================================================
# UPDATE HUD
# ============================================================

func _on_evolution_points_changed(
	current_points: int,
	banked_points: int
) -> void:

	evolution_label.text = (
		"Evolution Points: "
		+ str(current_points)
		+ "\nBanked: "
		+ str(banked_points)
	)
