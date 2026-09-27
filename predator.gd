extends CharacterBody2D


# ============================================================
# PREDATOR
# ============================================================
#
# Detects the player, pursues them, attacks when they enter
# the attack area, then retreats briefly before attacking again.
# ============================================================


# ============================================================
# MOVEMENT
# ============================================================

@export var swim_speed: float = 180.0
@export var acceleration: float = 300.0
@export var drag: float = 150.0


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

@onready var sprite: Sprite2D = $Sprite2D

@onready var attack_area: Area2D = $AttackArea


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
# PHYSICS
# ============================================================

func _physics_process(delta: float) -> void:

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
	# NO TARGET
	# --------------------------------------------------------

	if target == null:

		velocity = velocity.move_toward(
			Vector2.ZERO,
			drag * delta
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
# ATTACK
# ============================================================

func attack_target() -> void:

	if target == null:
		return


	if not target.has_method("take_damage"):
		return


	# --------------------------------------------------------
	# DAMAGE
	# --------------------------------------------------------

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
	# RETREAT DIRECTION
	# --------------------------------------------------------

	retreat_direction = (
		global_position
		- target.global_position
	).normalized()


	if retreat_direction == Vector2.ZERO:

		retreat_direction = Vector2.LEFT


	# --------------------------------------------------------
	# START RETREAT
	# --------------------------------------------------------

	retreat_timer = retreat_duration

	velocity = (
		retreat_direction
		* retreat_speed
	)


# ============================================================
# VISUAL FACING
# ============================================================

func update_visual_facing(
	direction: Vector2
) -> void:

	if direction.x < -0.05:

		sprite.flip_h = true


	elif direction.x > 0.05:

		sprite.flip_h = false


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
