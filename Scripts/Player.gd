extends CharacterBody2D

@export var speed = 50
@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar = $UI/HealthBar
@onready var stamina_bar = $UI/StaminaBar
@onready var ammo_amount = $UI/AmmoAmount
@onready var health_amount = $UI/HealthAmount
@onready var stamina_amount = $UI/StaminaAmount

var is_attacking = false
var new_direction = Vector2(0,1)
var animation

var health = 10
var max_health = 100
var regen_health = 1
var stamina = 100
var max_stamina = 100
var regen_stamina = 5
var stamina_exhausted = false
var regen_stamina_threshold = 50

signal health_updated
signal stamina_updated
signal ammo_pickups_updated
signal health_pickups_updated
signal stamina_pickups_updated

enum Pickups { AMMO, STAMINA, HEALTH }
var ammo_pickup = 5
var health_pickup = 1
var stamina_pickup = 1

func _ready():
	health_updated.connect(health_bar.update_health_ui)
	stamina_updated.connect(stamina_bar.update_stamina_ui)
	ammo_pickups_updated.connect(ammo_amount.update_ammo_amount_ui)
	health_pickups_updated.connect(health_amount.update_health_amount_ui)
	stamina_pickups_updated.connect(stamina_amount.update_stamina_amount_ui)

func _process(delta):
	var updated_heath = min(health + regen_health * delta, max_health)
	if updated_heath != health:
		health = updated_heath
		health_updated.emit(health, max_health)
	
	var updated_stamina = min(stamina + regen_stamina * delta, max_stamina)
	if updated_stamina != stamina:
		stamina = updated_stamina
		stamina_updated.emit(stamina, max_stamina)
		if stamina >= regen_stamina_threshold:
			stamina_exhausted = false

func _physics_process(delta):
	
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") -Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") -Input.get_action_strength("ui_up")
	
	#If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	if Input.is_action_pressed("ui_sprint"):
		if stamina >= 25 && !stamina_exhausted:
			speed = 100
			stamina = stamina - 20 * delta
			stamina_updated.emit(stamina, max_stamina)
		else:
			speed = 50
			stamina_exhausted = true
			stamina_updated.emit(stamina, max_stamina)
				
	elif Input.is_action_just_released("ui_sprint"):
		speed = 50
	
	var movement = speed * direction * delta

	if is_attacking == false:
		move_and_collide(movement)
		player_animations(direction)
		
	if !Input.is_anything_pressed():
		if is_attacking == false:
			animation = "idle_" + returned_direction(new_direction)


func player_animations(direction: Vector2):
	if direction != Vector2.ZERO:
		new_direction = direction
		animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		new_direction = direction
		animation = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)


func returned_direction(direction: Vector2):
	var normalized_direction = direction.normalized()
	var default_return = "side"
	
	if normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	elif normalized_direction.x > 0:
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x < 0:
		$AnimatedSprite2D.flip_h = true
		return "side"
		
	return default_return	


func _input(event):
	if event.is_action_pressed("ui_attack"):
		is_attacking = true
		var animation = "attack_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	if event.is_action_pressed("ui_consume_health"):
		if health_pickup > 0 && health > 0:
			health = min(health + 50, max_health)
			health_pickup = health_pickup - 1
			health_updated.emit(health, max_health)
			health_pickups_updated.emit(health_pickup)
	if event.is_action_pressed("ui_consume_stamina"):
		if stamina_pickup > 0 && stamina >= 0:
			stamina_pickup = stamina_pickup - 1
			stamina = min(stamina + 50, max_stamina)
			stamina_updated.emit(stamina, max_stamina)
			stamina_pickups_updated.emit(stamina_pickup)

func _on_animated_sprite_2d_animation_finished():
	is_attacking = false

func add_pickup(item):
	if item == Global.Pickups.AMMO:
		ammo_pickup = ammo_pickup + 3
		ammo_pickups_updated.emit(ammo_pickup)
		print("ammo val: " + str(ammo_pickup))
	if item == Global.Pickups.HEALTH:
		health_pickup = health_pickup + 1
		health_pickups_updated.emit(health_pickup)
		print("health val: " + str(health_pickup))
	if item == Global.Pickups.STAMINA:
		stamina_pickup = stamina_pickup + 1
		stamina_pickups_updated.emit(stamina_pickup)
		print("stamina val: " + str(stamina_pickup))	
