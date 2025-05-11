extends Node3D
class_name Piece

static var blockScene: Resource = preload("res://scenes/Block.tscn")
static var pieceScene: Resource = preload("res://scenes/Piece.tscn")
static var pieceLookup: Resource = preload("res://scripts/pieceblocks.tres")

var pieceBlocks: Node3D

var belongBoard: PlayBoard
var blockCollection: Array[Block]

var boardPos: Vector2i
var blockId: int
var rotationId: int

var pieceSet: bool = false
var controllingPiece: bool = true

static func make_piece(board: PlayBoard, pieceId: int, rotationId: int = 0, initBoardPos: Vector2i = Vector2i(3,2), irs: bool = false) -> Piece:
	var piece: Piece = pieceScene.instantiate()
	piece.belongBoard = board
	piece.boardPos = initBoardPos
	piece.position = Vector3(initBoardPos.x, -initBoardPos.y, 0)
	piece.blockId = pieceId
	if pieceId != 0 and irs:
		if Input.is_action_pressed("input_rotate_clockwise"):
			rotationId = 1
		elif Input.is_action_pressed("input_rotate_counterclockwise"):
			rotationId = pieceLookup.blockShapes[pieceId].size()-1
		else:
			rotationId = rotationId
	
	piece.rotationId = rotationId
	
	piece.blockCollection = []
	
	# internal block configurations
	var pieceBlockLocations: Array = pieceLookup.blockShapes[pieceId][rotationId]
	for blocki: int in range(4):
		var pieceBlock: Block = blockScene.instantiate()
		var blockPos: Vector2i = pieceBlockLocations[blocki]
		pieceBlock.boardPos = piece.boardPos+blockPos
		pieceBlock.position = Vector3(blockPos.x, -blockPos.y, 0)
		piece.blockCollection.append(pieceBlock)
		
		pieceBlock.set_block_color(pieceLookup.blockColors[pieceId])
		pieceBlock.set_block_color_id(pieceId)
		piece.get_node("PieceBlocks").add_child(pieceBlock)
	
	return piece

func _ready() -> void:
	pieceBlocks = get_node("PieceBlocks")

func can_move_down() -> bool:
	var success: bool = false
	var testPiece: Piece = make_piece(belongBoard, blockId, rotationId, Vector2i(boardPos.x, boardPos.y+1))
	if not belongBoard.is_piece_overlapping(testPiece):
		success = true
	else:
		success = false
	testPiece.queue_free()
	return success

func attempt_move_piece_horizontally(dir: int) -> void:
	var testPiece: Piece = make_piece(belongBoard, blockId, rotationId, Vector2i(boardPos.x+dir, boardPos.y))
	if not belongBoard.is_piece_overlapping(testPiece):
		transfer_test_piece_data(testPiece)
		
	testPiece.queue_free()

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

func attempt_piece_fast_drop() -> void:
	while attempt_move_piece_down():
		pass

func attempt_rotate_piece(dir: int) -> void:
	var newRotId: int = rotationId+dir
	if newRotId < 0:
		newRotId = pieceLookup.blockShapes[blockId].size()-1
	elif newRotId >= pieceLookup.blockShapes[blockId].size():
		newRotId = 0
	
	var testPiece: Piece = make_piece(belongBoard, blockId, newRotId, Vector2i(boardPos.x, boardPos.y))
	if not belongBoard.is_piece_overlapping(testPiece):
		transfer_test_piece_data(testPiece)
		testPiece.queue_free()
		return
	
	# attempt wallkicks
	if blockId != 6:
		testPiece.queue_free()
		testPiece = make_piece(belongBoard, blockId, newRotId, Vector2i(boardPos.x+1, boardPos.y))
		if not belongBoard.is_piece_overlapping(testPiece):
			transfer_test_piece_data(testPiece)
			testPiece.queue_free()
			return
		
		testPiece.queue_free()
		testPiece = make_piece(belongBoard, blockId, newRotId, Vector2i(boardPos.x-1, boardPos.y))
		if not belongBoard.is_piece_overlapping(testPiece):
			transfer_test_piece_data(testPiece)
			testPiece.queue_free()
			return
	
	testPiece.queue_free()
	


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

func _process(delta: float) -> void:
	position = Vector3(boardPos.x, -boardPos.y, 0)
	if pieceSet:
		queue_free()
