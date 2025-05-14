extends Node3D
class_name Block
## Handles individual blocks that exist on the board, whether placed or as a part of a piece.

## Links the index on a given block texture that corresponds to a block's piece ID in the TGM theming. 
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

## Position of the block in the board's internal array representation of the board.
## [br][br]
## Incrementing the x value would move the block towards the right, and incrementing the y value would move the block towards the bottom of the board.
var boardPos: Vector2i

## Used in a previous implementation of displaying the color of a block.
var blockColor: Color

## Represents the color that a block is supposed to take on.
## [br][br]
## With a 7-Piece implementation, -1 would indicate a gray/garbage block, while all ids above -1 and below 7 would correlate to unique piece colors.
var blockColorId: int

## Indicates if the block is placed in the stack of the board.
var placed: bool = false

## Indicates the progress made towards locking the block onto the board. 
## [br][br]
## Used as a shader parameter for blocks that are part of controlled pieces.
## [br][br]
## Should only span between 0.0 and 1.0.
var lockProgress: float = 0.0

func _ready() -> void:
	pass
	#%BlockMesh.set_instance_shader_parameter("lockProgress", lockProgress)

## Updates the lock progress to be 1.
func set_placed() -> void:
	lockProgress = 1.0

## Updates the lock progress counter and the material's lock progress parameter.
func set_lock_progress(lockProg: float) -> void:
	lockProgress = lockProg
	%BlockMesh.get_surface_override_material(0).set_shader_parameter("lock_progress", lockProgress)
	#%BlockMesh.set_instance_shader_parameter("lockProgress", lockProgress)

## Assigns a ShaderMaterial to the block's display mesh.
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

## Logic for displaying the outline of the block given an array of directions
## where the outline should be shown, which should be directions where there are
## no adjacent blocks.
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
			

## Updates the block's position in the scene based on its position in the board.
func move_to_board_pos() -> void:
	position = Vector3(boardPos.x, -boardPos.y, 0)

func _process(_delta: float) -> void:
	if get_parent().get_parent() is PlayBoard:
		move_to_board_pos()
