extends Node
class_name BoardInput

signal update_das(count: int)

var dasCounter: int = -1

func _process(delta: float):
	process_das_inputs()
	handle_board_inputs()

func process_das_inputs() -> void:
	if Input.is_action_just_pressed("input_piece_left"):
		init_das(-1)
	if Input.is_action_pressed("input_piece_left"):
		continue_das()
	if Input.is_action_just_pressed("input_piece_right"):
		init_das(1)
	if Input.is_action_pressed("input_piece_right"):
		continue_das()

func handle_board_inputs():
	var focusPiece: Piece = %BoardGameState.activePiece
	if focusPiece and focusPiece.controllingPiece:
		if Input.is_action_pressed("input_piece_down"):
			var moved: bool = focusPiece.attempt_move_piece_down()
			if not moved:
				%BoardGrid.set_piece_to_board(focusPiece)
		if focusPiece == null or not focusPiece.controllingPiece:
			return
		if Input.is_action_just_pressed("input_rotate_counterclockwise"):
			focusPiece.attempt_rotate_piece(-1)
		if Input.is_action_just_pressed("input_rotate_clockwise"):
			focusPiece.attempt_rotate_piece(1)
		if Input.is_action_just_pressed("input_piece_fast_drop"):
			focusPiece.attempt_piece_fast_drop()
		
		

func init_das(dir: int):
	dasCounter = Lookups.get_das_delay(%Subs.get_node("BoardGameState").level)
	#print(dasCounter)
	var chosenPiece: Piece
	if %Pieces.get_children().size() != 0:
		chosenPiece = %Pieces.get_child(0)
	else:
		chosenPiece = null
	if chosenPiece != null and chosenPiece.controllingPiece:
		chosenPiece.attempt_move_piece_horizontally(dir)

func continue_das():
	var chosenPiece: Piece
	if %Pieces.get_children().size() != 0:
		chosenPiece = %Pieces.get_child(0)
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


func _on_board_init_play() -> void:
	pass # Replace with function body.
