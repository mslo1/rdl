extends ColorRect

@onready var value = $Value

func update_stamina_ui(stamina, max_stamina):
	value.size.x = stamina * 98 / max_stamina

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
