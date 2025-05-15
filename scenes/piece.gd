extends Node3D
class_name Piece
## Represents a piece comprised of [Block]s.

## Instance default block scene.
static var blockScene: Resource = preload("res://scenes/Block.tscn")

## Instance default piece scene.
static var pieceScene: Resource = preload("res://scenes/Piece.tscn")

## Instance scene for piece shapes.
static var pieceLookup: Resource = preload("res://scripts/pieceblocks.tres")

## Reference to the container of blocks that comprise the piece.
var pieceBlocks: Node3D

## Reference to the board that the piece is a part of.
var belongBoard: PlayBoard

## Reference to the [Block]s held as children in the piece.
var blockCollection: Array[Block]

## Position of the piece on its board.
var boardPos: Vector2i

## The type of piece that this piece represents.
## The order should follow:
## [br][br]
## 0: O
## [br][br]
## 1: J
## [br][br]
## 2: L
## [br][br]
## 3: Z
## [br][br]
## 4: S
## [br][br]
## 5: T
## [br][br]
## 6: I
var blockId: int

## The number associated with the piece's rotation. A value of zero represents a rotation where
## the flattest side of the piece is facing upwards on the board, and is placed as horizontally as possible.
## Incrementing the value represents a clockwise rotation, decrementing represents a counterclockwise
## rotation. Should be restricted to values between 0 and 3, inclusive.
var rotationId: int

## A value of [code]false[\code] indicates the piece is separated from the stack, 
## [code]true[\code] indicates the piece is slated to become a part of the stack.
var pieceSet: bool = false

## indicates if the piece is controllable.
var controllingPiece: bool = true

## Prepares a piece that can be placed into the scene tree immediately.
static func make_piece(board: PlayBoard, pieceId: int, rotId: int = 0, initBoardPos: Vector2i = Vector2i(3,2), irs: bool = false) -> Piece:
	var piece: Piece = pieceScene.instantiate()
	piece.belongBoard = board
	piece.boardPos = initBoardPos
	piece.position = Vector3(initBoardPos.x, -initBoardPos.y, 0)
	piece.blockId = pieceId
	if pieceId != 0 and irs:
		if Input.is_action_pressed("input_rotate_clockwise"):
			rotId = 1
		elif Input.is_action_pressed("input_rotate_counterclockwise"):
			rotId = pieceLookup.blockShapes[pieceId].size()-1
		else:
			rotId = rotId
	
	piece.rotationId = rotId
	
	piece.blockCollection = []
	
	# internal block configurations
	var pieceBlockLocations: Array = pieceLookup.blockShapes[pieceId][rotId]
	for blocki: int in range(4):
		var pieceBlock: Block = blockScene.instantiate()
		var blockPos: Vector2i = pieceBlockLocations[blocki]
		pieceBlock.boardPos = piece.boardPos+blockPos
		pieceBlock.position = Vector3(blockPos.x, -blockPos.y, 0)
		piece.blockCollection.append(pieceBlock)
		pieceBlock.blockColorId = pieceId
		pieceBlock.set_block_material(board.block_mat)
		piece.get_node("PieceBlocks").add_child(pieceBlock)
		
	
	return piece

func _ready() -> void:
	pieceBlocks = get_node("PieceBlocks")

## Tests if a piece can move downwards in the [Board] it belongs in.
func can_move_down() -> bool:
	var success: bool = false
	var testPiece: Piece = make_piece(belongBoard, blockId, rotationId, Vector2i(boardPos.x, boardPos.y+1))
	if not belongBoard.is_piece_overlapping(testPiece):
		success = true
	else:
		success = false
	testPiece.queue_free()
	return success

## If able to, moves the piece horizontally by [param dir] blocks.
func attempt_move_piece_horizontally(dir: int) -> bool:
	var testPiece: Piece = make_piece(belongBoard, blockId, rotationId, Vector2i(boardPos.x+dir, boardPos.y))
	var success: bool = not belongBoard.is_piece_overlapping(testPiece)
	if success:
		transfer_test_piece_data(testPiece)
		
	testPiece.queue_free()
	return success

## If able to, moves the piece down the board by one block.
func attempt_move_piece_down() -> bool:
	var success: bool = false
	var testPiece: Piece = make_piece(belongBoard, blockId, rotationId, Vector2i(boardPos.x, boardPos.y+1))
	if not belongBoard.is_piece_overlapping(testPiece):
		transfer_test_piece_data(testPiece)
		success = true
	else:
		success = false
	testPiece.queue_free()
	return success

## Moves the piece as far down the board as possible.
func attempt_piece_fast_drop() -> void:
	while attempt_move_piece_down():
		pass

## Attempts to apply a rotation in the direction given. Accounts for TGM style rotation cases.
func attempt_rotate_piece(dir: int) -> void:
	var newRotId: int = rotationId+dir
	if newRotId < 0:
		newRotId = pieceLookup.blockShapes[blockId].size()-1
	elif newRotId >= pieceLookup.blockShapes[blockId].size():
		newRotId = 0
	
	if blockId in [1, 2, 5] and rotationId % 2 == 0:
		if not belongBoard.special_rotation_check(boardPos):
			return
		
	
	if check_apply_rotation(newRotId, 0):
		return
	
	# attempt wallkicks
	if blockId != 6:
		if check_apply_rotation(newRotId, 1):
			return
		
		if check_apply_rotation(newRotId, -1):
			return
	
## Checks the board for if a given piece is able to rotate there according to TGM rules. Only used for L, J and T pieces.
func check_apply_rotation(rot: int, dir: int) -> bool:
	var testPiece: Piece = make_piece(belongBoard, blockId, rot, Vector2i(boardPos.x+dir, boardPos.y))
	if not belongBoard.is_piece_overlapping(testPiece):
		transfer_test_piece_data(testPiece)
		testPiece.queue_free()
		return true
	else:
		testPiece.queue_free()
		return false

## Applies functional piece data from a test piece.
func transfer_test_piece_data(testPiece: Piece) -> void:
	boardPos = testPiece.boardPos
	rotationId = testPiece.rotationId
	blockCollection = testPiece.blockCollection
	if pieceBlocks:
		for n: Block in pieceBlocks.get_children():
			get_node("PieceBlocks").remove_child(n)
			n.queue_free()
	for n: Block in testPiece.blockCollection:
		testPiece.get_node("PieceBlocks").remove_child(n)
		pieceBlocks.add_child(n)
		n.set_block_material(belongBoard.locking_block_mat)

func _process(_delta: float) -> void:
	position = Vector3(boardPos.x, -boardPos.y, 0)
	if pieceSet:
		queue_free()
