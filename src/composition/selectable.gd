extends Node3D
class_name Selectable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_to_group("selectable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
