extends Node3D
class_name Board

var blockBoard : Array[Array]

var boardSizex: int = 10
var boardSizey: int = 21

var areCounter: int = -1
var dasCounter: int = -1

var level: int = 0

func block_board_init() -> void:
	blockBoard = []
	for rowi in range(boardSizey):
		var blockRow = []
		for coli in range(boardSizex):
			blockRow.append(null)
		blockBoard.append(blockRow)

func _ready() -> void:
	#add_child(Piece.makePiece(0))
	block_board_init()
	add_piece()
	

func add_piece() -> void:
	get_node("Pieces").add_child(Piece.make_piece(self, 1))

func process_counters() -> void:
	process_are_counter()

func process_are_counter() -> void:
	if areCounter == -1:
		pass
	elif areCounter > 0:
		areCounter -= 1
	elif areCounter == 0:
		areCounter -= 1
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
	var chosenPiece: Piece = get_node("Pieces").get_child(0)
	if chosenPiece.controllingPiece:
		chosenPiece.attempt_move_piece_horizontally(dir)

func continue_das():
	var chosenPiece: Piece = get_node("Pieces").get_child(0)
	if not (Input.is_action_just_pressed("input_piece_left") and Input.is_action_just_pressed("input_piece_left")) and dasCounter > -1:
		dasCounter -= 1
		if dasCounter < 0:
			dasCounter = 0
			if chosenPiece.controllingPiece:
				var moveDir: int = 0
				if Input.is_action_pressed("input_piece_left"):
					moveDir-=1
				if Input.is_action_pressed("input_piece_right"):
					moveDir+=1
				chosenPiece.attempt_move_piece_horizontally(moveDir)
		
func _process(delta: float) -> void:
	process_das_inputs()
	process_counters()
