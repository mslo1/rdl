extends ColorRect

@onready var value = $Value
@onready var player = $"../.."

func update_stamina_amount_ui(staminaAmount):
	value.text = str(staminaAmount);

# Called when the node enters the scene tree for the first time.
func _ready():
	value.text = str(player.stamina_pickup)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
