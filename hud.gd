extends CanvasLayer


# ============================================================
# HUD REFERENCES
# ============================================================

@onready var ui: Control = $UI
@onready var evolution_label: Label = $UI/EvolutionLabel


# ============================================================
# EVOLUTION SCREEN REFERENCES
# ============================================================

@onready var evolution_screen: Control = $EvolutionScreen

@onready var generation_label: Label = (
	$EvolutionScreen/Panel/VBoxContainer/GenerationLabel
)

@onready var banked_label: Label = (
	$EvolutionScreen/Panel/VBoxContainer/BankedLabel
)

@onready var jaws_button: Button = (
	$EvolutionScreen/Panel/VBoxContainer/JawsButton
)

@onready var fins_button: Button = (
	$EvolutionScreen/Panel/VBoxContainer/FinsButton
)

@onready var tail_button: Button = (
	$EvolutionScreen/Panel/VBoxContainer/TailButton
)

@onready var sensory_button: Button = (
	$EvolutionScreen/Panel/VBoxContainer/SensoryButton
)

@onready var armor_button: Button = (
	$EvolutionScreen/Panel/VBoxContainer/ArmorButton
)

@onready var next_generation_button: Button = (
	$EvolutionScreen/Panel/VBoxContainer/NextGenerationButton
)

# ============================================================
# PLAYER REFERENCE
# ============================================================

var player: CharacterBody2D = null


# ============================================================
# HUD STATE
# ============================================================

var current_points: int = 0
var banked_points: int = 0

var current_health: float = 0.0
var maximum_health: float = 0.0

var mate_nearby: bool = false


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	ui.position = Vector2.ZERO
	ui.size = get_viewport().get_visible_rect().size

	evolution_label.position = Vector2(
		20.0,
		20.0
	)

	evolution_label.size = Vector2(
		500.0,
		200.0
	)


	evolution_screen.visible = false


	# --------------------------------------------------------
	# CONNECT BUTTONS
	# --------------------------------------------------------

	jaws_button.pressed.connect(
		_on_jaws_pressed
	)

	fins_button.pressed.connect(
		_on_fins_pressed
	)

	tail_button.pressed.connect(
		_on_tail_pressed
	)

	sensory_button.pressed.connect(
		_on_sensory_pressed
	)

	armor_button.pressed.connect(
		_on_armor_pressed
	)

	next_generation_button.pressed.connect(
		_on_next_generation_pressed
	)


	# --------------------------------------------------------
	# FIND PLAYER
	# --------------------------------------------------------

	find_and_connect_player()


# ============================================================
# FIND / CONNECT PLAYER
# ============================================================

func find_and_connect_player() -> void:

	player = get_tree().get_first_node_in_group(
		"player"
	) as CharacterBody2D


	if player == null:

		push_warning(
			"HUD could not find the Player."
		)

		return


	player.evolution_points_changed.connect(
		_on_evolution_points_changed
	)

	player.health_changed.connect(
		_on_health_changed
	)

	player.mate_range_changed.connect(
		_on_mate_range_changed
	)

	player.died.connect(
		_on_player_died
	)


	current_points = player.evolution_points
	banked_points = LineageManager.banked_evolution_points

	current_health = player.health
	maximum_health = player.max_health

	mate_nearby = false

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
# HEALTH UPDATE
# ============================================================

func _on_health_changed(
	new_health: float,
	new_max_health: float
) -> void:

	current_health = new_health
	maximum_health = new_max_health

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
# PLAYER DIED
# ============================================================

func _on_player_died(
	_preserved_points: int
) -> void:

	mate_nearby = false

	show_evolution_screen()


# ============================================================
# MAIN HUD
# ============================================================

func update_hud() -> void:

	var hud_text: String = (
		"Generation: "
		+ str(LineageManager.generation)
		+ "\nHealth: "
		+ str(roundi(current_health))
		+ " / "
		+ str(roundi(maximum_health))
		+ "\nEvolution Points: "
		+ str(current_points)
		+ "\nBanked: "
		+ str(LineageManager.banked_evolution_points)
	)


	if mate_nearby:

		hud_text += (
			"\n\nCompatible Mate Nearby"
			+ "\n[E] / [Y] Reproduce"
		)


	evolution_label.text = hud_text


# ============================================================
# SHOW EVOLUTION SCREEN
# ============================================================

func show_evolution_screen() -> void:

	evolution_screen.visible = true

	update_evolution_screen()


# ============================================================
# UPDATE EVOLUTION SCREEN
# ============================================================

func update_evolution_screen() -> void:

	generation_label.text = (
		"Generation "
		+ str(LineageManager.generation)
		+ " has ended."
	)

	banked_label.text = (
		"Preserved Evolution Points: "
		+ str(LineageManager.banked_evolution_points)
	)


	# --------------------------------------------------------
	# JAWS
	# --------------------------------------------------------

	if LineageManager.has_jaws:

		jaws_button.text = "Jaws — EVOLVED"
		jaws_button.disabled = true

	else:

		jaws_button.text = (
			"Jaws — "
			+ str(LineageManager.JAWS_COST)
			+ " EP"
		)

		jaws_button.disabled = (
			not LineageManager.can_afford(
				LineageManager.JAWS_COST
			)
		)


	# --------------------------------------------------------
	# PAIRED FINS
	# --------------------------------------------------------

	if LineageManager.has_paired_fins:

		fins_button.text = "Paired Fins — EVOLVED"
		fins_button.disabled = true

	else:

		fins_button.text = (
			"Paired Fins — "
			+ str(LineageManager.PAIRED_FINS_COST)
			+ " EP"
		)

		fins_button.disabled = (
			not LineageManager.can_afford(
				LineageManager.PAIRED_FINS_COST
			)
		)


	# --------------------------------------------------------
	# IMPROVED TAIL
	# --------------------------------------------------------

	if LineageManager.has_improved_tail:

		tail_button.text = "Improved Tail — EVOLVED"
		tail_button.disabled = true

	else:

		tail_button.text = (
			"Improved Tail — "
			+ str(LineageManager.IMPROVED_TAIL_COST)
			+ " EP"
		)

		tail_button.disabled = (
			not LineageManager.can_afford(
				LineageManager.IMPROVED_TAIL_COST
			)
		)


	# --------------------------------------------------------
	# SENSORY ORGANS
	# --------------------------------------------------------

	if LineageManager.has_sensory_organs:

		sensory_button.text = "Sensory Organs — EVOLVED"
		sensory_button.disabled = true

	else:

		sensory_button.text = (
			"Sensory Organs — "
			+ str(LineageManager.SENSORY_ORGANS_COST)
			+ " EP"
		)

		sensory_button.disabled = (
			not LineageManager.can_afford(
				LineageManager.SENSORY_ORGANS_COST
			)
		)


	# --------------------------------------------------------
	# DERMAL ARMOR
	# --------------------------------------------------------

	if LineageManager.has_dermal_armor:

		armor_button.text = "Dermal Armor — EVOLVED"
		armor_button.disabled = true

	else:

		armor_button.text = (
			"Dermal Armor — "
			+ str(LineageManager.DERMAL_ARMOR_COST)
			+ " EP"
		)

		armor_button.disabled = (
			not LineageManager.can_afford(
				LineageManager.DERMAL_ARMOR_COST
			)
		)


# ============================================================
# PURCHASE BUTTONS
# ============================================================

func _on_jaws_pressed() -> void:

	var purchased: bool = LineageManager.purchase_jaws()

	if purchased:
		print("EVOLUTION PURCHASED: Jaws")

	update_evolution_screen()


func _on_fins_pressed() -> void:

	var purchased: bool = LineageManager.purchase_paired_fins()

	if purchased:
		print("EVOLUTION PURCHASED: Paired Fins")

	update_evolution_screen()


func _on_tail_pressed() -> void:

	var purchased: bool = LineageManager.purchase_improved_tail()

	if purchased:
		print("EVOLUTION PURCHASED: Improved Tail")

	update_evolution_screen()


func _on_sensory_pressed() -> void:

	var purchased: bool = LineageManager.purchase_sensory_organs()

	if purchased:
		print("EVOLUTION PURCHASED: Sensory Organs")

	update_evolution_screen()


func _on_armor_pressed() -> void:

	var purchased: bool = LineageManager.purchase_dermal_armor()

	if purchased:
		print("EVOLUTION PURCHASED: Dermal Armor")

	update_evolution_screen()


# ============================================================
# BEGIN NEXT GENERATION
# ============================================================

func _on_next_generation_pressed() -> void:

	LineageManager.begin_next_generation()

	get_tree().reload_current_scene()
