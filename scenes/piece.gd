extends Node3D
class_name Piece

static var blockScene: Resource = preload("res://scenes/Block.tscn")
static var pieceScene: Resource = preload("res://scenes/Piece.tscn")
static var pieceLookup: Resource = preload("res://scripts/pieceblocks.tres")

var pieceBlocks: Node3D

var belongBoard: Board
var blockCollection: Array[Block]

var boardPos: Vector2i = Vector2i(3, 1)
var blockId: int
var rotationId: int

static func make_piece(board: Board, blockId: int, rotationId: int = 0, initBoardPos: Vector2i = Vector2i(3,1)) -> Piece:
	var piece: Piece = pieceScene.instantiate()
	piece.belongBoard = board
	piece.boardPos = initBoardPos
	piece.blockId = blockId
	piece.rotationId = rotationId
	var pieceBlockLocations: Array = pieceLookup.blocks[blockId][rotationId]
	piece.blockCollection = []
	for blocki in range(4):
		var pieceBlock: Block = blockScene.instantiate()
		var blockPos: Vector2i = pieceBlockLocations[blocki]
		pieceBlock.boardPos = piece.boardPos+blockPos
		pieceBlock.position = Vector3(blockPos.x, -blockPos.y, 0)
		piece.blockCollection.append(pieceBlock)
		piece.get_node("PieceBlocks").add_child(pieceBlock)
	return piece

static func is_piece_overlapping(piece: Piece) -> bool:
	if piece.belongBoard == null:
		return false
	for block in piece.blockCollection:
		var boardFocPos: Vector2i = block.boardPos
		if boardFocPos.x < 0: return true
		if boardFocPos.x >= piece.belongBoard.boardSizex: return true
		if boardFocPos.y < 0: return true
		if boardFocPos.y > piece.belongBoard.boardSizey: return true
		if piece.belongBoard.blockBoard[boardFocPos.y-1][boardFocPos.x] != null:
			return true
	return false

func _ready() -> void:
	pieceBlocks = get_node("PieceBlocks")

func handle_board_inputs():
	if Input.is_action_just_pressed("input_rotate_counterclockwise"):
		attempt_rotate_piece(-1)
	if Input.is_action_just_pressed("input_rotate_clockwise"):
		attempt_rotate_piece(1)
	if Input.is_action_just_pressed("input_piece_left"):
		attempt_move_piece_horizontally(-1)
	if Input.is_action_just_pressed("input_piece_right"):
		attempt_move_piece_horizontally(1)
	if Input.is_action_pressed("input_piece_down"):
		attempt_move_piece_down()

func attempt_move_piece_horizontally(dir: int):
	var testPiece: Piece = make_piece(belongBoard, blockId, rotationId, Vector2i(boardPos.x+dir, boardPos.y))
	if not is_piece_overlapping(testPiece):
		transfer_test_piece_data(testPiece)
	testPiece.queue_free()

func attempt_move_piece_down() -> void:
	var testPiece: Piece = make_piece(belongBoard, blockId, rotationId, Vector2i(boardPos.x, boardPos.y+1))
	if not is_piece_overlapping(testPiece):
		transfer_test_piece_data(testPiece)
	else:
		set_piece_to_board()
	testPiece.queue_free()

func attempt_rotate_piece(dir: int) -> void:
	var newRotId = rotationId+dir
	if newRotId < 0:
		newRotId = pieceLookup.blocks[blockId].size()-1
	elif newRotId >= pieceLookup.blocks[blockId].size():
		newRotId = 0
	
	var testPiece: Piece = make_piece(belongBoard, blockId, newRotId, Vector2i(boardPos.x, boardPos.y))
	if not is_piece_overlapping(testPiece):
		transfer_test_piece_data(testPiece)
		testPiece.queue_free()
		return
	
	if blockId != 6:
		testPiece.queue_free()
		testPiece = make_piece(belongBoard, blockId, newRotId, Vector2i(boardPos.x+1, boardPos.y))
		if not is_piece_overlapping(testPiece):
			transfer_test_piece_data(testPiece)
			testPiece.queue_free()
			return
		
		testPiece.queue_free()
		testPiece = make_piece(belongBoard, blockId, newRotId, Vector2i(boardPos.x-1, boardPos.y))
		if not is_piece_overlapping(testPiece):
			transfer_test_piece_data(testPiece)
			testPiece.queue_free()
			return
	
	testPiece.queue_free()
	
	
func set_piece_to_board() -> void:
	for block in blockCollection:
		block.position = Vector3(block.boardPos.x, -block.boardPos.y,0)
		block.get_parent().remove_child(block)
		belongBoard.get_node("Blocks").add_child(block)
		belongBoard.blockBoard[block.boardPos.y-1][block.boardPos.x] = block
	belongBoard.get_node("Pieces").remove_child(self)
	belongBoard.get_node("Pieces").add_child(make_piece(belongBoard, 1))
	queue_free()

func transfer_test_piece_data(testPiece: Piece) -> void:
	boardPos = testPiece.boardPos
	rotationId = testPiece.rotationId
	blockCollection = testPiece.blockCollection
	for n in pieceBlocks.get_children():
		get_node("PieceBlocks").remove_child(n)
		n.queue_free()
	for n in testPiece.blockCollection:
		testPiece.get_node("PieceBlocks").remove_child(n)
		pieceBlocks.add_child(n)

func _process(delta: float) -> void:
	handle_board_inputs()
	
	
	position = Vector3(boardPos.x, -boardPos.y, 0)
	
