extends Node
class_name BoardGameState

signal drop_blocks()

const maxPieceIdHistory: int = 6
const maxPieceGenerateTries: int = 6
var pieceIdHistory: Array[int] = []

var activePiece: Piece

var areCounter: int = -1
var lineClearAreCounter: int = -1

var level: int = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	process_counters()

func _on_board_init_play() -> void:
	pieceIdHistory = []
	areCounter = -1
	lineClearAreCounter = -1
	level = 0
	generate_next_piece(true)
	add_piece()

func process_counters() -> void:
	process_are_counter()
	process_line_clear_are_counter()	

func set_are_line_delay() -> void:
	areCounter = Lookups.get_line_are_delay(level)

func set_are_delay() -> void:
	areCounter = Lookups.get_are_delay(level)

func process_are_counter() -> void:
	if areCounter == -1:
		pass
	elif areCounter > 0:
		areCounter -= 1
	elif areCounter == 0:
		areCounter -= 1
		# split behavior if locking the current piece would clear lines
		if %BoardGrid.linesToClear.size() != 0:
			%BoardGrid.drop_blocks_to_floor()
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


func generate_next_piece(start: int) -> void:
	# remove whatever nextpiece exists
	if %NextPiece.get_children() != []:
		%NextPiece.get_child(0).queue_free()
	
	# piece pulling algorithm
	var genPieceId = RandomNumberGenerator.new().randi_range(0,6)
	if start:
		while genPieceId == 0 or genPieceId == 3 or genPieceId == 4:
			genPieceId = RandomNumberGenerator.new().randi_range(0,6)
	else:
		var generateTries: int = 0
		while genPieceId in pieceIdHistory and generateTries < maxPieceGenerateTries:
			genPieceId = RandomNumberGenerator.new().randi_range(0,6)
			generateTries+=1
	
	# piece recording
	pieceIdHistory.append(genPieceId)
	if pieceIdHistory.size() > maxPieceIdHistory:
		pieceIdHistory.remove_at(0)
	
	# generating piece to display
	var nextPiece: Piece = Piece.make_piece(get_parent().get_parent(), genPieceId)
	nextPiece.controllingPiece = false
	#print(pieceIdHistory)
	%NextPiece.add_child(nextPiece)
	
func add_piece() -> void:
	var nextID: int = %NextPiece.get_child(0).blockId
	var newPiece: Piece = Piece.make_piece(%Subs.get_parent(), nextID, 0, Vector2i(3,1), true)
	%Pieces.add_child(newPiece)
	activePiece = newPiece
	generate_next_piece(false)
