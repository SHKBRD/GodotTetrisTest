extends Node3D
class_name Board

var blockBoard : Array[Array]

var boardSizex: int = 10
var boardSizey: int = 21

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
	get_node("Pieces").add_child(Piece.make_piece(self, 1))
	
	
func _process(delta: float) -> void:
	pass
