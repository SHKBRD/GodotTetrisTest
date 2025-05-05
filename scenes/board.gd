extends Node3D
class_name Board

var blockBoard : Array[Array]
var linesToClear: Array[int] = []

var boardSizex: int = 10
var boardSizey: int = 21

var areCounter: int = -1
var lineClearAreCounter: int = -1
var dasCounter: int = -1

var level: int = 0

func block_board_init() -> void:
	blockBoard = []
	for rowi in range(boardSizey):
		var blockRow = []
		for coli in range(boardSizex):
			blockRow.append(null)
		blockBoard.append(blockRow)

func get_full_line_inds() -> Array[int]:
	var fullLineInds: Array[int] = []
	for boardRowInd: int in range(blockBoard.size()):
		var isFull: bool = true
		for block: Block in blockBoard[boardRowInd]:
			if block == null:
				isFull = false
				break
		if isFull: fullLineInds.append(boardRowInd)
	return fullLineInds
	
func _ready() -> void:
	#add_child(Piece.makePiece(0))
	block_board_init()
	add_piece()
	

func add_piece() -> void:
	get_node("Pieces").add_child(Piece.make_piece(self, 6))

func clear_blocks_on_rows(fullLineInds) -> void:
	for rowInd: int in fullLineInds:
		for block: Block in blockBoard[rowInd]:
			%Blocks.remove_child(block)

# deals with the position of the blocks after the initial ARE of putting down the line after a line clear
func drop_blocks_to_floor() -> void:
	var rowsToAdd: int = 0
	# clear out existing blocks, remove rows to drop pieces above
	for rowIndInd: int in range(linesToClear.size()-1, -1, -1):
		for block: Block in blockBoard[linesToClear[rowIndInd]]:
			block.queue_free()
		blockBoard.remove_at(linesToClear[rowIndInd])
		rowsToAdd+=1
	
	# add rows at the top
	for row in rowsToAdd:
		var newEmptyBlockRow: Array[Block] = []
		for col in boardSizex:
			newEmptyBlockRow.append(null)
		blockBoard.insert(0,newEmptyBlockRow)
	
	# update positions of existing blocks to match their new positions
	for rowi: int in blockBoard.size():
		for coli: int in blockBoard[rowi].size():
			var referenceBlock: Block = blockBoard[rowi][coli]
			if blockBoard[rowi][coli] != null:
				referenceBlock.boardPos = Vector2i(coli, rowi)
				referenceBlock.position = Vector3(coli, -rowi-1, 0)

func process_counters() -> void:
	process_are_counter()
	process_line_clear_are_counter()	

func process_are_counter() -> void:
	if areCounter == -1:
		pass
	elif areCounter > 0:
		areCounter -= 1
	elif areCounter == 0:
		areCounter -= 1
		if linesToClear.size() != 0:
			drop_blocks_to_floor()
			lineClearAreCounter = Lookups.get_line_clear_are_delay(level)
		else:
			add_piece()

func process_line_clear_are_counter()	:
	if lineClearAreCounter == -1:
		pass
	elif lineClearAreCounter > 0:
		lineClearAreCounter -= 1
	elif lineClearAreCounter == 0:
		lineClearAreCounter -= 1
		add_piece()

func process_das_inputs() -> void:
	if Input.is_action_just_pressed("input_piece_left"):
		init_das(-1)
	if Input.is_action_pressed("input_piece_left"):
		continue_das()
	if Input.is_action_just_pressed("input_piece_right"):
		init_das(1)
	if Input.is_action_pressed("input_piece_right"):
		continue_das()

func init_das(dir: int):
	dasCounter = Lookups.get_das_delay(level)
	print(dasCounter)
	var chosenPiece: Piece
	if get_node("Pieces").get_children().size() != 0:
		chosenPiece = get_node("Pieces").get_child(0)
	else:
		chosenPiece = null
	if chosenPiece != null and chosenPiece.controllingPiece:
		chosenPiece.attempt_move_piece_horizontally(dir)

func continue_das():
	var chosenPiece: Piece
	if get_node("Pieces").get_children().size() != 0:
		chosenPiece = get_node("Pieces").get_child(0)
	else:
		chosenPiece = null
	if not (Input.is_action_just_pressed("input_piece_left") and Input.is_action_just_pressed("input_piece_left")) and dasCounter > -1:
		dasCounter -= 1
		if dasCounter < 0:
			dasCounter = 0
			if chosenPiece != null and chosenPiece.controllingPiece:
				var moveDir: int = 0
				if Input.is_action_pressed("input_piece_left"):
					moveDir-=1
				if Input.is_action_pressed("input_piece_right"):
					moveDir+=1
				chosenPiece.attempt_move_piece_horizontally(moveDir)
		
func _process(delta: float) -> void:
	process_das_inputs()
	process_counters()
