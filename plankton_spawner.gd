extends Node2D


# ============================================================
# PLANKTON SPAWNER
# ============================================================

@export var plankton_scene: PackedScene

@export var initial_plankton_count: int = 300
@export var max_plankton: int = 400
@export var spawn_interval: float = 1.0


# ============================================================
# WORLD SIZE
# ============================================================

@export var world_left: float = -6000.0
@export var world_right: float = 6000.0
@export var world_top: float = -2000.0
@export var world_bottom: float = 2000.0


# ============================================================
# PLANKTON CLOUDS
# ============================================================

# Number of feeding grounds distributed around the ocean.
@export var cloud_count: int = 15

# Approximate radius of each feeding ground.
@export var cloud_radius: float = 450.0

# Chance that newly spawned plankton belongs to a cloud.
# The remainder spawns sparsely throughout the ocean.
@export_range(0.0, 1.0) var cloud_spawn_chance: float = 0.85


var cloud_centers: Array[Vector2] = []
var spawn_timer: float = 0.0


func _ready() -> void:

	create_cloud_centers()

	for i in range(initial_plankton_count):
		spawn_plankton()


func _process(delta: float) -> void:

	spawn_timer += delta

	if spawn_timer >= spawn_interval:

		spawn_timer = 0.0

		var plankton_count: int = get_tree().get_nodes_in_group(
			"plankton"
		).size()

		if plankton_count < max_plankton:
			spawn_plankton()


# ============================================================
# CREATE FEEDING GROUNDS
# ============================================================

func create_cloud_centers() -> void:

	cloud_centers.clear()

	for i in range(cloud_count):

		var center := Vector2(
			randf_range(world_left, world_right),
			randf_range(world_top, world_bottom)
		)

		cloud_centers.append(center)


# ============================================================
# SPAWN PLANKTON
# ============================================================

func spawn_plankton() -> void:

	if plankton_scene == null:
		push_warning(
			"PlanktonSpawner has no Plankton Scene assigned."
		)
		return

	var plankton := plankton_scene.instantiate()

	var spawn_position: Vector2


	# --------------------------------------------------------
	# CLOUD SPAWN
	# --------------------------------------------------------

	if (
		randf() < cloud_spawn_chance
		and not cloud_centers.is_empty()
	):

		var cloud_index: int = randi_range(
			0,
			cloud_centers.size() - 1
		)

		var center: Vector2 = cloud_centers[cloud_index]

		var angle: float = randf_range(
			0.0,
			TAU
		)

		# Multiplying two random values biases plankton toward
		# the center while still allowing a fuzzy outer edge.
		var distance: float = (
			randf()
			* randf()
			* cloud_radius
		)

		var offset := Vector2.RIGHT.rotated(angle) * distance

		spawn_position = center + offset


	# --------------------------------------------------------
	# SPARSE OPEN-WATER SPAWN
	# --------------------------------------------------------

	else:

		spawn_position = Vector2(
			randf_range(world_left, world_right),
			randf_range(world_top, world_bottom)
		)


	# Keep plankton inside the playable ocean.
	spawn_position.x = clamp(
		spawn_position.x,
		world_left,
		world_right
	)

	spawn_position.y = clamp(
		spawn_position.y,
		world_top,
		world_bottom
	)


	plankton.position = spawn_position

	plankton.add_to_group("plankton")

	add_child(plankton)
