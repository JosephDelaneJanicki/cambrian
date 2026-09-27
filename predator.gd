extends CharacterBody2D


# ============================================================
# PREDATOR
# ============================================================
#
# Detects the player, pursues them, attacks at close range,
# retreats after attacking, and can be killed by jaws.
#
# BodyPivot controls the predator's directional anatomy:
# sprite, physical collision, and attack hitbox.
# ============================================================


# ============================================================
# MOVEMENT
# ============================================================

@export var swim_speed: float = 180.0
@export var acceleration: float = 300.0
@export var drag: float = 150.0


# ============================================================
# HEALTH
# ============================================================

@export var max_health: float = 100.0

var health: float = 100.0
var is_dead: bool = false


# ============================================================
# ATTACK
# ============================================================

@export var attack_damage: float = 25.0
@export var attack_cooldown: float = 1.25

@export var retreat_duration: float = 0.65
@export var retreat_speed: float = 260.0


# ============================================================
# NODE REFERENCES
# ============================================================

@onready var body_pivot: Node2D = $BodyPivot

@onready var sprite: Sprite2D = (
	$BodyPivot/Sprite2D
)

@onready var attack_area: Area2D = (
	$BodyPivot/AttackArea
)

# ============================================================
# WANDERING
# ============================================================

@export var wander_speed: float = 65.0

@export var wander_change_min: float = 2.0
@export var wander_change_max: float = 5.0

var wander_direction: Vector2 = Vector2.RIGHT
var wander_timer: float = 0.0

func choose_new_wander_direction() -> void:

	wander_direction = Vector2.RIGHT.rotated(
		randf_range(
			0.0,
			TAU
		)
	)


	wander_timer = randf_range(
		wander_change_min,
		wander_change_max
	)
# ============================================================
# TARGET STATE
# ============================================================

var target: CharacterBody2D = null


# ============================================================
# ATTACK STATE
# ============================================================

var attack_timer: float = 0.0

var retreat_timer: float = 0.0
var retreat_direction: Vector2 = Vector2.ZERO


# ============================================================
# FACING STATE
# ============================================================

var facing_left: bool = false


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	health = max_health
	choose_new_wander_direction()
	update_visual_facing(
		Vector2.RIGHT
	)


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta: float) -> void:

	if is_dead:
		return


	# --------------------------------------------------------
	# TIMERS
	# --------------------------------------------------------

	if attack_timer > 0.0:
		attack_timer -= delta


	if retreat_timer > 0.0:
		retreat_timer -= delta


	# --------------------------------------------------------
	# RETREAT
	# --------------------------------------------------------

	if retreat_timer > 0.0:

		velocity = velocity.move_toward(
			retreat_direction * retreat_speed,
			acceleration * 2.0 * delta
		)

		update_visual_facing(
			retreat_direction
		)

		move_and_slide()

		return


	# --------------------------------------------------------
	# WANDER
	# --------------------------------------------------------

	if target == null:

		wander_timer -= delta


		if wander_timer <= 0.0:

			choose_new_wander_direction()


		velocity = velocity.move_toward(
			wander_direction * wander_speed,
			acceleration * delta
		)


		update_visual_facing(
			wander_direction
		)


		move_and_slide()

		return


	# --------------------------------------------------------
	# VALIDATE TARGET
	# --------------------------------------------------------

	if not is_instance_valid(target):

		target = null

		return


	if target.is_dead:

		target = null

		return


	# --------------------------------------------------------
	# DIRECTION TO PLAYER
	# --------------------------------------------------------

	var direction: Vector2 = (
		target.global_position
		- global_position
	).normalized()


	# --------------------------------------------------------
	# ATTACK CHECK
	# --------------------------------------------------------

	if (
		attack_timer <= 0.0
		and is_target_in_attack_area()
	):

		attack_target()

		return


	# --------------------------------------------------------
	# CHASE
	# --------------------------------------------------------

	velocity = velocity.move_toward(
		direction * swim_speed,
		acceleration * delta
	)


	update_visual_facing(
		direction
	)


	move_and_slide()


# ============================================================
# ATTACK AREA CHECK
# ============================================================

func is_target_in_attack_area() -> bool:

	if target == null:
		return false


	var overlapping_bodies: Array[Node2D] = (
		attack_area.get_overlapping_bodies()
	)


	for body: Node2D in overlapping_bodies:

		if body == target:
			return true


	return false


# ============================================================
# ATTACK PLAYER
# ============================================================

func attack_target() -> void:

	if target == null:
		return


	if not target.has_method("take_damage"):
		return


	target.take_damage(
		attack_damage
	)


	print(
		"Predator bite! Damage: ",
		attack_damage
	)


	# --------------------------------------------------------
	# COOLDOWN
	# --------------------------------------------------------

	attack_timer = attack_cooldown


	# --------------------------------------------------------
	# RETREAT
	# --------------------------------------------------------

	retreat_direction = (
		global_position
		- target.global_position
	).normalized()


	if retreat_direction == Vector2.ZERO:

		retreat_direction = Vector2.LEFT


	retreat_timer = retreat_duration


	velocity = (
		retreat_direction
		* retreat_speed
	)


# ============================================================
# TAKE DAMAGE
# ============================================================

func take_damage(amount: float) -> void:

	if is_dead:
		return


	health = max(
		health - amount,
		0.0
	)


	print(
		"Predator took ",
		amount,
		" damage. Health: ",
		health,
		"/",
		max_health
	)


	if health <= 0.0:
		die()


# ============================================================
# DEATH
# ============================================================

func die() -> void:

	if is_dead:
		return


	is_dead = true
	velocity = Vector2.ZERO


	print(
		"Predator killed!"
	)


	queue_free()


# ============================================================
# ORIENTATION
# ============================================================

func update_visual_facing(
	direction: Vector2
) -> void:

	if direction == Vector2.ZERO:
		return


	# --------------------------------------------------------
	# DETERMINE FACING
	# --------------------------------------------------------

	if direction.x < -0.05:

		facing_left = true


	elif direction.x > 0.05:

		facing_left = false


	# --------------------------------------------------------
	# MIRROR ENTIRE PREDATOR BODY
	# --------------------------------------------------------
	#
	# Because Sprite2D, physical collision, and AttackArea
	# all live underneath BodyPivot, they flip together.
	# --------------------------------------------------------

	if facing_left:

		body_pivot.scale.x = -abs(
			body_pivot.scale.x
		)

	else:

		body_pivot.scale.x = abs(
			body_pivot.scale.x
		)


# ============================================================
# DETECTION
# ============================================================

func _on_detection_area_body_entered(
	body: Node2D
) -> void:

	if not body.is_in_group("player"):
		return


	target = body as CharacterBody2D


	print(
		"Predator detected player!"
	)


func _on_detection_area_body_exited(
	body: Node2D
) -> void:

	if body != target:
		return


	target = null


	print(
		"Player escaped predator!"
	)
