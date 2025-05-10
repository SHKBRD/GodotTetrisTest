extends Node3D
class_name PlayBoard

signal init_play()

	
func _ready() -> void:
	#add_child(Piece.makePiece(0))
	init_play.emit()
	#block_board_init()
	#generate_next_piece(true)
	#add_piece()
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset_board"):
		board_reset()
		init_play.emit()

func board_reset() -> void:
	for child in %Pieces.get_children():
		%Pieces.remove_child(child)
		child.queue_free()
	for child in %Blocks.get_children():
		%Blocks.remove_child(child)
		child.queue_free()
	for child in %NextPiece.get_children():
		%NextPiece.remove_child(child)
		child.queue_free()
	%BoardGameState.activePiece = null
	

# easy access methods
func is_piece_overlapping(piece: Piece) -> bool:
	return %BoardGrid.is_piece_overlapping(piece)
