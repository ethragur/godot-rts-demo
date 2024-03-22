extends Camera3D
class_name TopDownCamera

@export_category("Zoom")
@export var zoom_max : float = 20.0
@export var zoom_min : float = 5.0
@export var zoom_sen: float = 0.5
@export var angle: float = 80.0

@export_category("Movement")
@export var move_buffer: float = 5.0
@export var move_speed: float = 1.0


const screen_xy_ration: float = 16.0/9.0


@onready var selector: Control = $Selector
var clicking: bool = false
var selecting: bool = false

const click_limit = 2.0

var move: Vector2 = Vector2.ZERO

var prev_mouse_pos: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		self.zoom(1.0)
	if event.is_action_pressed("camera_zoom_out"):
		self.zoom(-1.0)
		
	if event.is_action_pressed("select"):
		clicking = true
	if event.is_action_released("select"):
		if clicking:
			print("Clicked")
			clicking = false
		if selecting:
			print("Selected")
			selecting = false
			self.selector.visible = false
			self.get_selectables(self.selector.pos, self.selector.res)
			self.selector.pos = Vector2.ZERO
			self.selector.res = Vector2.ZERO

func zoom(amount: float):
	var new_pos : float = self.position.y + (amount * self.zoom_sen)
	self.position.y = clampf(new_pos, self.zoom_min, self.zoom_max)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func get_selectables(pos: Vector2, res: Vector2):
	var dropPlane  = Plane(Vector3(0, 1, 0), 0)

	var start = dropPlane.intersects_ray(self.project_ray_origin(pos),self.project_ray_normal(pos))
	var end   = dropPlane.intersects_ray(self.project_ray_origin(pos + res),self.project_ray_normal(pos + res))

	var rect : Rect2 = Rect2()
	rect.position = Vector2(start.x, start.z)
	rect.end = Vector2(end.x, end.z)
	rect = rect.abs()
	
	var selectables: Array[Node] = get_tree().get_nodes_in_group("selectable")
	var in_area: Array[Selectable] = []
	
	for s in selectables:
		if rect.has_point(Vector2(s.global_position.x, s.global_position.z)):
			in_area.push_back(s)

	return in_area

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()

	if mouse_pos.x <  move_buffer * screen_xy_ration:
		move += Vector2(-1.0, 0.0)
	if mouse_pos.x > get_viewport().get_window().size.x - move_buffer * screen_xy_ration:
		move += Vector2(1.0, 0.0)
	if mouse_pos.y < move_buffer:
		move += Vector2(0.0, -1.0)
	if mouse_pos.y > get_viewport().get_window().size.y - move_buffer:
		move += Vector2(0.0, 1.0)
	self.global_translate(Vector3(move.x, 0.0, move.y) * move_speed * delta * self.position.y)
	self.move = Vector2.ZERO
	
	
	if (clicking and self.prev_mouse_pos.distance_to(mouse_pos) > click_limit):
		print("%v, %v" % [self.selector.pos, mouse_pos])
		clicking = false
		selecting = true
		self.selector.pos = mouse_pos
		self.selector.visible = true
		
	if selecting:
		selecting = true
		clicking = false
		self.selector.res = mouse_pos - self.selector.pos
		self.selector.queue_redraw()
		
	self.prev_mouse_pos = mouse_pos
