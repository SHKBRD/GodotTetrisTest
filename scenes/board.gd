extends Node3D
class_name PlayBoard

	
func _ready() -> void:
	#add_child(Piece.makePiece(0))
	init_play()
	#block_board_init()
	#generate_next_piece(true)
	#add_piece()

func init_play() -> void:
	%BoardGrid.block_board_init()
	%BoardGameState.board_game_state_init()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset_board"):
		board_reset()
		init_play()

func board_reset() -> void:
	for child: Piece in %Pieces.get_children():
		%Pieces.remove_child(child)
		child.queue_free()
	for child: Block in %Blocks.get_children():
		%Blocks.remove_child(child)
		child.queue_free()
	for child: Piece in %NextPiece.get_children():
		%NextPiece.remove_child(child)
		child.queue_free()
	%BoardGameState.activePiece = null
	

# easy access methods
func is_piece_overlapping(piece: Piece) -> bool:
	return %BoardGrid.is_piece_overlapping(piece)
