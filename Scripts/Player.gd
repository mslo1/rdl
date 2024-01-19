extends CharacterBody2D

@export var speed = 50
@onready var animation_sprite = $AnimatedSprite2D
@onready var health_bar = $UI/HealthBar
@onready var stamina_bar = $UI/StaminaBar

var is_attacking = false
var new_direction = Vector2(0,1)
var animation

var health = 100
var max_health = 100
var regen_health = 1
var stamina = 100
var max_stamina = 100
var regen_stamina = 5

signal health_updated
signal stamina_updated

func _ready():
	health_updated.connect(health_bar.update_health_ui)
	stamina_updated.connect(stamina_bar.update_stamina_ui)

func _process(delta):
	var updated_heath = min(health + regen_health * delta, max_health)
	if updated_heath != health:
		health = updated_heath
		health_updated.emit(health, max_health)
	
	var updated_stamina = min(stamina + regen_stamina * delta, max_stamina)
	if updated_stamina != stamina:
		stamina = updated_stamina
		stamina_updated.emit(stamina, max_stamina)

func _physics_process(delta):
	
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") -Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") -Input.get_action_strength("ui_up")
	
	#If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	if Input.is_action_pressed("ui_sprint"):
		if stamina >= 25:
			speed = 100
			stamina = stamina - 1
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

func _on_animated_sprite_2d_animation_finished():
	is_attacking = false
