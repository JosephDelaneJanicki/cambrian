extends CharacterBody2D


# ============================================================
# SIGNALS
# ============================================================

signal evolution_points_changed(
	current_points: int,
	banked_points: int
)

signal mate_range_changed(
	in_range: bool
)

signal reproduced


# ============================================================
# MOVEMENT
# ============================================================

@export var max_speed: float = 250.0
@export var propulsion: float = 350.0
@export var drag: float = 80.0

@export_range(0.0, 89.0) var max_pitch_degrees: float = 80.0


# ============================================================
# EVOLUTION TRAITS
# ============================================================

var has_paired_fins: bool = false
var has_jaws: bool = false


# ============================================================
# EVOLUTION POINTS
# ============================================================

var evolution_points: int = 0
var banked_evolution_points: int = 0


# ============================================================
# REPRODUCTION STATE
# ============================================================

var nearby_mate: Area2D = null


# ============================================================
# NODE REFERENCES
# ============================================================

@onready var fish_body: Node2D = $FishBody

@onready var feeding_pivot: Node2D = $FeedingPivot
@onready var feeding_area: Area2D = $FeedingPivot/FeedingArea

@onready var body_collision: CollisionShape2D = $CollisionShape2D


# ============================================================
# MOVEMENT STATE
# ============================================================

var facing_direction: Vector2 = Vector2.RIGHT


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	fish_body.apply_evolution(
		has_jaws,
		has_paired_fins
	)

	update_orientation()


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta: float) -> void:

	# --------------------------------------------------------
	# DIRECTIONAL INPUT
	# --------------------------------------------------------

	var input_direction: Vector2 = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)


	# --------------------------------------------------------
	# AIM
	# --------------------------------------------------------

	if input_direction != Vector2.ZERO:

		facing_direction = input_direction.normalized()

		update_orientation()


	# --------------------------------------------------------
	# PROPULSION
	# --------------------------------------------------------

	if Input.is_action_pressed("propel"):

		velocity += (
			facing_direction
			* propulsion
			* delta
		)

		velocity = velocity.limit_length(
			max_speed
		)


	# --------------------------------------------------------
	# WATER DRAG
	# --------------------------------------------------------

	else:

		velocity = velocity.move_toward(
			Vector2.ZERO,
			drag * delta
		)


	# --------------------------------------------------------
	# REPRODUCTION INPUT
	# --------------------------------------------------------

	if Input.is_action_just_pressed("reproduce"):
		attempt_reproduction()


	# --------------------------------------------------------
	# APPLY MOVEMENT
	# --------------------------------------------------------

	move_and_slide()


# ============================================================
# ORIENTATION
# ============================================================

func update_orientation() -> void:

	if facing_direction == Vector2.ZERO:
		return


	# --------------------------------------------------------
	# VISUAL BODY
	# --------------------------------------------------------

	fish_body.set_orientation(
		facing_direction,
		max_pitch_degrees
	)

	var facing_left: bool = fish_body.is_facing_left()


	# --------------------------------------------------------
	# CALCULATE PITCH
	# --------------------------------------------------------

	var pitch: float = atan2(
		facing_direction.y,
		abs(facing_direction.x)
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
	# FEEDING AREA
	# --------------------------------------------------------

	# Keep this exactly as our known-good transform setup.

	if facing_left:

		feeding_pivot.scale = Vector2(
			-1.0,
			1.0
		)

		feeding_pivot.rotation = -pitch

	else:

		feeding_pivot.scale = Vector2.ONE

		feeding_pivot.rotation = pitch


	# --------------------------------------------------------
	# BODY COLLISION
	# --------------------------------------------------------

	body_collision.rotation = pitch


# ============================================================
# FEEDING
# ============================================================

func _on_feeding_area_area_entered(area: Area2D) -> void:

	if area.has_method("consume"):

		var gained_ep: int = area.consume()

		add_evolution_points(
			gained_ep
		)


# ============================================================
# EVOLUTION POINT MANAGEMENT
# ============================================================

func add_evolution_points(amount: int) -> void:

	evolution_points += amount

	evolution_points_changed.emit(
		evolution_points,
		banked_evolution_points
	)

	print(
		"Evolution Points: ",
		evolution_points,
		" | Banked: ",
		banked_evolution_points
	)


# ============================================================
# MATE RANGE
# ============================================================

func set_nearby_mate(mate: Area2D) -> void:

	nearby_mate = mate

	mate_range_changed.emit(true)


func clear_nearby_mate(mate: Area2D) -> void:

	# Don't clear a different mate if multiple mates
	# eventually overlap their detection ranges.
	if nearby_mate != mate:
		return

	nearby_mate = null

	mate_range_changed.emit(false)


# ============================================================
# REPRODUCTION
# ============================================================

func attempt_reproduction() -> void:

	if nearby_mate == null:
		print("No compatible mate nearby.")
		return

	if not is_instance_valid(nearby_mate):
		nearby_mate = null
		mate_range_changed.emit(false)
		return

	if not nearby_mate.has_method("can_reproduce_with"):
		return

	if not nearby_mate.can_reproduce_with(self):
		print("Mate is currently unavailable.")
		return


	# --------------------------------------------------------
	# BANK CURRENT PROGRESS
	# --------------------------------------------------------

	banked_evolution_points = evolution_points


	# --------------------------------------------------------
	# TELL MATE REPRODUCTION OCCURRED
	# --------------------------------------------------------

	if nearby_mate.has_method("on_reproduction"):
		nearby_mate.on_reproduction(self)


	# --------------------------------------------------------
	# UPDATE HUD
	# --------------------------------------------------------

	evolution_points_changed.emit(
		evolution_points,
		banked_evolution_points
	)

	reproduced.emit()

	print(
		"Reproduction successful! ",
		"Banked Evolution Points: ",
		banked_evolution_points
	)
