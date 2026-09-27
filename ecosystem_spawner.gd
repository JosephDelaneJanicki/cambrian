extends Node2D


# ============================================================
# ECOSYSTEM SPAWNER
# ============================================================

@export var mate_scene: PackedScene
@export var predator_scene: PackedScene

@export var max_mates: int = 5
@export var max_predators: int = 3

@export var spawn_radius: float = 1200.0
@export var minimum_spawn_distance: float = 450.0

@export var spawn_check_interval: float = 3.0


var spawn_timer: float = 0.0

var player: CharacterBody2D = null


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	player = get_tree().get_first_node_in_group(
		"player"
	) as CharacterBody2D


# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:

	if player == null:
		return

	if not is_instance_valid(player):
		return


	spawn_timer -= delta


	if spawn_timer <= 0.0:

		spawn_timer = spawn_check_interval

		maintain_population()


# ============================================================
# POPULATION
# ============================================================

func maintain_population() -> void:

	var mate_count: int = (
		get_tree()
		.get_nodes_in_group("mate")
		.size()
	)

	var predator_count: int = (
		get_tree()
		.get_nodes_in_group("predator")
		.size()
	)


	while mate_count < max_mates:

		spawn_mate()
		mate_count += 1


	while predator_count < max_predators:

		spawn_predator()
		predator_count += 1


# ============================================================
# SPAWN MATE
# ============================================================

func spawn_mate() -> void:

	if mate_scene == null:
		return


	var mate: Node2D = (
		mate_scene.instantiate()
		as Node2D
	)


	get_parent().add_child(mate)


	mate.global_position = (
		get_random_spawn_position()
	)


# ============================================================
# SPAWN PREDATOR
# ============================================================

func spawn_predator() -> void:

	if predator_scene == null:
		return


	var predator: Node2D = (
		predator_scene.instantiate()
		as Node2D
	)


	get_parent().add_child(predator)


	predator.global_position = (
		get_random_spawn_position()
	)


# ============================================================
# RANDOM SPAWN POSITION
# ============================================================

func get_random_spawn_position() -> Vector2:

	var direction: Vector2 = Vector2.RIGHT.rotated(
		randf_range(
			0.0,
			TAU
		)
	)


	var distance: float = randf_range(
		minimum_spawn_distance,
		spawn_radius
	)


	return (
		player.global_position
		+ direction * distance
	)
