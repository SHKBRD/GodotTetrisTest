extends Node3D
class_name Block

var boardPos: Vector2i
var blockColor: Color
var placed: bool = false

func _ready() -> void:
	pass

func set_block_color(color: Color) -> void:
	blockColor = color
	%BlockMesh.set_instance_shader_parameter("blockColor", color)

func set_placed(placedState: bool) -> void:
	self.placed = placedState
	%BlockMesh.set_instance_shader_parameter("placed", placedState)

func move_to_board_pos() -> void:
	position = Vector3(boardPos.x, -boardPos.y, 0)

func _process(delta: float) -> void:
	if get_parent().get_parent() is PlayBoard:
		move_to_board_pos()
