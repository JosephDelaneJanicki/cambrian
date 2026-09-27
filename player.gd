extends CharacterBody2D


# ============================================================
# SIGNALS
# ============================================================

signal evolution_points_changed(
	current_points: int,
	banked_points: int
)

signal health_changed(
	current_health: float,
	maximum_health: float
)

signal mate_range_changed(
	in_range: bool
)

signal reproduced

signal died(
	banked_points: int
)


# ============================================================
# BASE MOVEMENT
# ============================================================

@export var max_speed: float = 250.0
@export var propulsion: float = 350.0
@export var drag: float = 80.0

@export_range(0.0, 89.0) var max_pitch_degrees: float = 80.0


# ============================================================
# HEALTH
# ============================================================

@export var max_health: float = 100.0

var health: float = 100.0
var is_dead: bool = false


# ============================================================
# CURRENT-LIFE EVOLUTION POINTS
# ============================================================

var evolution_points: int = 0


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

	health = max_health

	apply_lineage_state()

	update_orientation()

	health_changed.emit(
		health,
		max_health
	)

	evolution_points_changed.emit(
		evolution_points,
		LineageManager.banked_evolution_points
	)


# ============================================================
# APPLY LINEAGE STATE
# ============================================================

func apply_lineage_state() -> void:

	fish_body.apply_evolution(
		LineageManager.has_jaws,
		LineageManager.has_paired_fins,
		LineageManager.has_improved_tail,
		LineageManager.has_sensory_organs,
		LineageManager.has_dermal_armor
	)


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta: float) -> void:

	if is_dead:
		return


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
			* get_current_propulsion()
			* delta
		)

		velocity = velocity.limit_length(
			get_current_max_speed()
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
	# REPRODUCTION
	# --------------------------------------------------------

	if Input.is_action_just_pressed("reproduce"):

		attempt_reproduction()


	move_and_slide()


# ============================================================
# ORIENTATION
# ============================================================

func update_orientation() -> void:

	if facing_direction == Vector2.ZERO:
		return


	fish_body.set_orientation(
		facing_direction,
		max_pitch_degrees
	)

	var facing_left: bool = fish_body.is_facing_left()


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
	# KNOWN-GOOD FEEDING TRANSFORM
	# --------------------------------------------------------

	if facing_left:

		feeding_pivot.scale = Vector2(
			-1.0,
			1.0
		)

		feeding_pivot.rotation = -pitch

	else:

		feeding_pivot.scale = Vector2.ONE

		feeding_pivot.rotation = pitch


	body_collision.rotation = pitch


# ============================================================
# HEALTH / DAMAGE
# ============================================================

func take_damage(amount: float) -> void:

	if is_dead:
		return


	var final_damage: float = (
		amount
		* get_damage_modifier()
	)


	health = max(
		health - final_damage,
		0.0
	)


	health_changed.emit(
		health,
		max_health
	)


	print(
		"Player took ",
		final_damage,
		" damage. Health: ",
		health,
		"/",
		max_health
	)


	if health <= 0.0:
		die()


func heal(amount: float) -> void:

	if is_dead:
		return


	health = min(
		health + amount,
		max_health
	)


	health_changed.emit(
		health,
		max_health
	)


# ============================================================
# DEATH
# ============================================================

func die() -> void:

	if is_dead:
		return


	is_dead = true
	velocity = Vector2.ZERO


	body_collision.set_deferred(
		"disabled",
		true
	)

	feeding_area.set_deferred(
		"monitoring",
		false
	)


	print(
		"Generation ",
		LineageManager.generation,
		" died."
	)

	print(
		"Current-life EP lost: ",
		evolution_points
	)

	print(
		"Banked lineage EP preserved: ",
		LineageManager.banked_evolution_points
	)


	died.emit(
		LineageManager.banked_evolution_points
	)


# ============================================================
# EVOLUTION EFFECTS
# ============================================================

func get_current_max_speed() -> float:

	if LineageManager.has_improved_tail:
		return max_speed * 1.35

	return max_speed


func get_current_propulsion() -> float:

	if LineageManager.has_improved_tail:
		return propulsion * 1.30

	return propulsion


func get_turning_modifier() -> float:

	if LineageManager.has_paired_fins:
		return 1.35

	return 1.0


func get_sensory_modifier() -> float:

	if LineageManager.has_sensory_organs:
		return 1.50

	return 1.0


func get_damage_modifier() -> float:

	if LineageManager.has_dermal_armor:
		return 0.65

	return 1.0


func can_bite() -> bool:

	return LineageManager.has_jaws


# ============================================================
# FEEDING
# ============================================================

func _on_feeding_area_area_entered(
	area: Area2D
) -> void:

	if is_dead:
		return


	if area.has_method("consume"):

		var gained_ep: int = area.consume()

		add_evolution_points(
			gained_ep
		)


# ============================================================
# EVOLUTION POINT MANAGEMENT
# ============================================================

func add_evolution_points(amount: int) -> void:

	if is_dead:
		return


	evolution_points += amount


	evolution_points_changed.emit(
		evolution_points,
		LineageManager.banked_evolution_points
	)


	print(
		"Evolution Points: ",
		evolution_points,
		" | Banked: ",
		LineageManager.banked_evolution_points
	)


# ============================================================
# MATE RANGE
# ============================================================

func set_nearby_mate(mate: Area2D) -> void:

	if is_dead:
		return


	nearby_mate = mate

	mate_range_changed.emit(true)


func clear_nearby_mate(mate: Area2D) -> void:

	if nearby_mate != mate:
		return


	nearby_mate = null

	mate_range_changed.emit(false)


# ============================================================
# REPRODUCTION
# ============================================================

func attempt_reproduction() -> void:

	if is_dead:
		return


	if nearby_mate == null:

		print(
			"No compatible mate nearby."
		)

		return


	if not is_instance_valid(nearby_mate):

		nearby_mate = null

		mate_range_changed.emit(false)

		return


	if not nearby_mate.has_method(
		"can_reproduce_with"
	):

		return


	if not nearby_mate.can_reproduce_with(self):

		print(
			"Mate is currently unavailable."
		)

		return


	# --------------------------------------------------------
	# SAVE LINEAGE CHECKPOINT
	# --------------------------------------------------------

	LineageManager.bank_progress(
		evolution_points,
		global_position
	)


	# --------------------------------------------------------
	# CONSUME MATE
	# --------------------------------------------------------

	if nearby_mate.has_method(
		"on_reproduction"
	):

		nearby_mate.on_reproduction(
			self
		)


	# --------------------------------------------------------
	# UPDATE HUD
	# --------------------------------------------------------

	evolution_points_changed.emit(
		evolution_points,
		LineageManager.banked_evolution_points
	)

	reproduced.emit()


	print(
		"Reproduction successful! ",
		"Banked Evolution Points: ",
		LineageManager.banked_evolution_points
	)
