extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var pos: Vector2 = Vector2.ZERO
var res: Vector2 = Vector2.ZERO

func _draw() -> void:
	draw_rect(Rect2(pos, res), Color.GREEN, false, 5.0)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
