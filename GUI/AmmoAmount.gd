extends ColorRect

@onready var value = $Value
@onready var player = $"../.."

func update_ammo_amount_ui(ammo):
	value.text = str(ammo);

# Called when the node enters the scene tree for the first time.
func _ready():
	value.text = str(player.ammo_pickup)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
