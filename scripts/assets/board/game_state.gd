extends Node
class_name BoardGameState
## Handles game state information within a particular game match/session.

## Emitted when reaching a new section.
signal section_elevate()

## Emitted when the board reaches a game over state.
signal game_over_init()

## Maximum pieces to be remembered in consideration for the piece randomization.
const maxPieceIdHistory: int = 6

## Maximum amount of attempts to generate a piece that follows generation rules.
const maxPieceGenerateTries: int = 6

## Current gamemode.
var gamemode: Gamemodes.Mode = Gamemodes.Mode.DEFAULT

## Stores past generated piece types for piece randomization.
var pieceIdHistory: Array[int] = []

## The board's current "playing" piece.
var activePiece: Piece

## Countdown used for the time delay immediately after locking a piece in.
## [br][br]
## -1 indicates the counter isn't active, values 0 and beyond indicate an active timer.
var areCounter: int = -1

## Countdown used for the time delay between a piece touching a surface of the board's stack and locking the piece in automatically.
## [br][br]
## -1 indicates the counter isn't active, values 0 and beyond indicate an active timer.
var lockDelay: int = -1

## Countdown used for the time delay between blocks being cleared and generating a new piece
## [br][br]
## -1 indicates the counter isn't active, values 0 and beyond indicate an active timer.
var lineClearAreCounter: int = -1

## Counter used for indicating how much gravity should be applied to a piece in one frame.
## [br][br]
## This counter should be positive at all times. This value is increased every frame by some
## set amount based on the current [member level].
## Every 256 units above 0 will indicate a block of gravity, and once gravity begins to be processed, 
## 256 will be subtracted from [member gravityProgress] until it reaches a value below 256.
var gravityProgress: int = 0

## Current section. Should be one section per 100 [member level]s.
var section: int = 0

## Current level. Indicates the amount of pieces placed and lines cleared, barring pieces 
## placed while at a section threshold.
var level: int = 0

## Maximum [member level] to be attained.
var maxLevel: int = 999



func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	process_counters()

## Resets core game state variables, prepares next piece and active piece.
func board_game_state_init() -> void:
	pieceIdHistory = []
	areCounter = -1
	lineClearAreCounter = -1
	lockDelay = -1
	level = 0
	section = int(level/100.0)
	if activePiece != null:
		activePiece.queue_free()
	generate_next_piece(true)
	add_piece()

## Increments [member level]. If [param clear] is enabled, [member section] can be passed if the current 
## [member level] is right before a [member section] threshold. 
## ([member section] thresholds are generally right before each multiple of 100, and one less than the
## maximum [member level].)
func increment_level(clear: bool) -> void:
	if level % 100 == 99 or level == maxLevel-1:
		if clear:
			level += 1
			section += 1
			section_elevate.emit()
	else:
		level += 1

## Runs through all available game state counters.
func process_counters() -> void:
	process_are_counter()
	process_line_clear_are_counter()
	process_gravity()
	process_lock_delay()
	%LevelCounter.update_level_counter(level, section)

## Assigns [member areCounter] its line delay based off the current [member level].
func set_are_line_delay() -> void:
	areCounter = Lookups.get_line_are_delay(level, gamemode)

## Assigns [member areCounter] its delay based off the current [member level].
func set_are_delay() -> void:
	areCounter = Lookups.get_are_delay(level, gamemode)

## Processes [member areCounter] and initiates ARE ending actions
## if [member areCounter] counts down to 0.
func process_are_counter() -> void:
	if areCounter == -1:
		pass
	elif areCounter > 0:
		areCounter -= 1
	elif areCounter == 0:
		areCounter -= 1
		are_counter_done()

## Initiates post-ARE countdown actions. Initiates [member lineClearAreCounter]
## if lines are cleared, otherwise adds the next piece.
func are_counter_done() -> void:
	if %BoardGrid.linesToClear.size() != 0:
		%BoardGrid.drop_blocks_to_floor()
		lineClearAreCounter = Lookups.get_line_clear_are_delay(level, gamemode)
	else:
		add_piece()

## Processes [member lineClearAreCounter] and adds next piece if [member lineClearAreCounter] counts down to 0.
func process_line_clear_are_counter() -> void:
	if lineClearAreCounter == -1:
		pass
	elif lineClearAreCounter > 0:
		lineClearAreCounter -= 1
	elif lineClearAreCounter == 0:
		lineClearAreCounter -= 1
		add_piece()

## Processes the [member gravityProgress] counter using the current [member level].
func process_gravity() -> void:
	if activePiece != null:
		gravityProgress += Lookups.get_gravity(level, gamemode)
		while gravityProgress/256.0 >= 1:
			if not activePiece.attempt_move_piece_down():
				gravityProgress = 0
				break
			else:
				lockDelay = -1
			gravityProgress-=256
	
		# updating position to make sure first frame isn't always the default position
		activePiece.position = Vector3(activePiece.boardPos.x, -activePiece.boardPos.y, 0)

## Processes the [member lockDelay] counter using the current [member level].
## Updates the [member lockDelay] of each block in [member activePiece],
## and calls [method BoardGrid.set_piece_to_board] with [member activePiece] once [member lockDelay]
## reaches 0. 
func process_lock_delay() -> void:
	if activePiece:
		if not activePiece.can_move_down():
			if lockDelay == -1:
				lockDelay = Lookups.get_lock_delay(level, gamemode)
			if lockDelay == 0:
				%BoardGrid.set_piece_to_board(activePiece)
				lockDelay = -1
			else:
				lockDelay -= 1
		else:
			lockDelay = -1
		# The earlier set_piece_to_board call when lockDelay runs out 
		if activePiece:
			update_piece_lock_progress(activePiece)

## Sets the [member lockDelay] into each block of the [member activePiece].
func update_piece_lock_progress(piece: Piece) -> void:
	var prog: float = 0.0
	if lockDelay != -1:
		prog = 1-(max(lockDelay, 0.0)/float(Lookups.get_lock_delay(level, gamemode)))
	#print(prog)
	for block: Block in piece.blockCollection:
		block.set_lock_progress(prog)

## Picks the next piece. [param start] indicates whether the possible pieces should be limited to the
## selection available at the very beginning of the game. (Does not pick O, S or Z pieces to prevent overhangs)
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
	
## Attempts to add the next available piece onto the board and [member activePiece]. 
## [br][br]
## If successful, [method generate_next_piece] is called and gravity is processed immediately, then
## the new piece is added to the scene tree.
## If both IRS and non-IRS checks fail, [signal game_over_init] is emitted.
func add_piece() -> void:
	var nextID: int = %NextPiece.get_child(0).blockId
	var newPiece: Piece = Piece.make_piece(%Subs.get_parent(), nextID, 0, Vector2i(3,2), true)
	if newPiece.belongBoard.is_piece_overlapping(newPiece):
		newPiece.queue_free()
		newPiece = Piece.make_piece(%Subs.get_parent(), nextID, 0, Vector2i(3,2), false)
		if newPiece.belongBoard.is_piece_overlapping(newPiece):
			newPiece.queue_free()
			game_over_init.emit()
			return
		
	for block: Block in newPiece.blockCollection:
		block.set_block_material(newPiece.belongBoard.locking_block_mat)
		
	%Pieces.add_child(newPiece)
	activePiece = newPiece
	gravityProgress = 0
	generate_next_piece(false)
	process_gravity()
