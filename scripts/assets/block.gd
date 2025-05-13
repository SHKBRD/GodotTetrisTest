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
var lockProgress: float = 0.0

func _ready() -> void:
	pass
	#%BlockMesh.set_instance_shader_parameter("lockProgress", lockProgress)

func set_block_color(color: Color) -> void:
	blockColor = color
	#%BlockMesh.set_instance_shader_parameter("blockColor", color)

func set_block_color_id(colorId: int) -> void:
	blockColorId = colorId
	#%BlockMesh.set_instance_shader_parameter("blockColorId", colorIdToTextureInd[blockColorId])

func set_placed(placedState: bool) -> void:
	if placedState == true:
		lockProgress = 1.0
	#%BlockMesh.set_instance_shader_parameter("lockProgress", lockProgress)

func set_lock_progress(lockProg: float) -> void:
	lockProgress = lockProg
	%BlockMesh.get_surface_override_material(0).set_shader_parameter("lock_progress", lockProgress)
	#%BlockMesh.set_instance_shader_parameter("lockProgress", lockProgress)

func set_block_material(mat: ShaderMaterial) -> void:
	#var pastMat: ShaderMaterial = %BlockMesh.get_surface_override_material(0)
	#if pastMat: pastMat.queue_free()
	var newMat: ShaderMaterial = mat.duplicate()
	var targetColorId: int = colorIdToTextureInd[blockColorId]
	var uvXOff: float = (targetColorId%4)/4.0
	var uvYOff: float = int(targetColorId/4.0)/4.0
	newMat.set_shader_parameter("uv1_offset", Vector3(uvXOff, uvYOff, 0.0))
	#print(newMat.get_shader_parameter("lock_progress"))
	newMat.set_shader_parameter("lock_progress", lockProgress)
	%BlockMesh.set_surface_override_material(0, newMat)

func update_outline(dirs: Array[Vector2i]) -> void:
	#print(dirs)
	if dirs.size() == 0:
		%BlockOutLines.hide()
	else:
		%BlockOutLines.show()
		%BlockOutlineN.hide()
		%BlockOutlineE.hide()
		%BlockOutlineS.hide()
		%BlockOutlineW.hide()
		if Vector2i.UP in dirs:
			%BlockOutlineN.show()
		if Vector2i.RIGHT in dirs:
			%BlockOutlineE.show()
		if Vector2i.DOWN in dirs:
			%BlockOutlineS.show()
		if Vector2i.LEFT in dirs:
			%BlockOutlineW.show()
			

func move_to_board_pos() -> void:
	position = Vector3(boardPos.x, -boardPos.y, 0)

func _process(_delta: float) -> void:
	if get_parent().get_parent() is PlayBoard:
		move_to_board_pos()
