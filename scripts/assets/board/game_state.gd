extends Node
class_name BoardGameState

signal drop_blocks()
signal section_elevate()

const maxPieceIdHistory: int = 6
const maxPieceGenerateTries: int = 6
var pieceIdHistory: Array[int] = []

var activePiece: Piece

var areCounter: int = -1
var lock_delay: int = -1
var lineClearAreCounter: int = -1
var gravityProgress: int = 0

var section: int = 0
var level: int = 0
var maxLevel: int = 999

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	process_counters()

func board_game_state_init() -> void:
	pieceIdHistory = []
	areCounter = -1
	lineClearAreCounter = -1
	lock_delay = -1
	level = 0
	section = int(level/100)
	generate_next_piece(true)
	add_piece()

func increment_level(clear: bool) -> void:
	if level % 100 == 99 or level == maxLevel-1:
		if clear:
			level += 1
			section += 1
			section_elevate.emit()
	else:
		level += 1

func process_counters() -> void:
	process_are_counter()
	process_line_clear_are_counter()
	process_gravity()
	process_lock_delay()
	%LevelCounter.update_level_counter(level, section)

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


func process_line_clear_are_counter() -> void:
	if lineClearAreCounter == -1:
		pass
	elif lineClearAreCounter > 0:
		lineClearAreCounter -= 1
	elif lineClearAreCounter == 0:
		lineClearAreCounter -= 1
		add_piece()


func process_gravity() -> void:
	if activePiece != null:
		gravityProgress += Lookups.get_gravity(level)
		while gravityProgress/256 >= 1:
			if not activePiece.attempt_move_piece_down():
				gravityProgress = 0
				break
			else:
				lock_delay = -1
			gravityProgress-=256
	
		# updating position to make sure first frame isn't always the default position
		activePiece.position = Vector3(activePiece.boardPos.x, -activePiece.boardPos.y, 0)

func process_lock_delay() -> void:
	if activePiece:
		if not activePiece.can_move_down():
			if lock_delay == -1:
				lock_delay = Lookups.get_lock_delay(level)
			if lock_delay == 0:
				%BoardGrid.set_piece_to_board(activePiece)
				lock_delay = -1
			else:
				lock_delay -= 1
		else:
			lock_delay = -1
		if activePiece:
			var prog: float = 1-(max(lock_delay, 0.0)/float(Lookups.get_lock_delay(level)))
			#print(prog)
			for block: Block in activePiece.blockCollection:
				block.set_lock_progress(prog)

func generate_next_piece(start: int) -> void:
	# remove whatever nextpiece exists
	if %NextPiece.get_children() != []:
		%NextPiece.get_child(0).queue_free()
	
	# piece pulling algorithm
	var genPieceId: int = RandomNumberGenerator.new().randi_range(0,6)
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
	var newPiece: Piece = Piece.make_piece(%Subs.get_parent(), nextID, 0, Vector2i(3,2), true)
	if newPiece.belongBoard.is_piece_overlapping(newPiece):
		newPiece = Piece.make_piece(%Subs.get_parent(), nextID, 0, Vector2i(3,2), false)
	%Pieces.add_child(newPiece)
	activePiece = newPiece
	gravityProgress = 0
	generate_next_piece(false)
	process_gravity()
