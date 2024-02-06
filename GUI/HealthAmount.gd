extends ColorRect

@onready var value = $Value
@onready var player = $"../.."

func update_health_amount_ui(healthAmount):
	value.text = str(healthAmount);

# Called when the node enters the scene tree for the first time.
func _ready():
	value.text = str(player.health_pickup)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
