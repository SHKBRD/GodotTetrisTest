extends Node3D
class_name Block

static var colorIdToTextureInd: Dictionary[int, int] = {
	-1: 0,
	0: 3,
	1: 6,
	2: 2,
	3: 7,
	4: 4,
	5: 5,
	6: 1
}

var boardPos: Vector2i
var blockColor: Color
var blockColorId: int
var placed: bool = false

func _ready() -> void:
	pass

func set_block_color(color: Color) -> void:
	blockColor = color
	%BlockMesh.set_instance_shader_parameter("blockColor", color)

func set_block_color_id(colorId: int) -> void:
	blockColorId = colorId
	%BlockMesh.set_instance_shader_parameter("blockColorId", colorIdToTextureInd[blockColorId])

func set_placed(placedState: bool) -> void:
	self.placed = placedState
	%BlockMesh.set_instance_shader_parameter("placed", placedState)

func set_lock_progress(lockProgress: float) -> void:
	%BlockMesh.set_instance_shader_parameter("lockProgress", lockProgress)

func move_to_board_pos() -> void:
	position = Vector3(boardPos.x, -boardPos.y, 0)

func _process(delta: float) -> void:
	if get_parent().get_parent() is PlayBoard:
		move_to_board_pos()
