extends Node
class_name BoardGrid

var blockBoard : Array[Array]
var linesToClear: Array[int] = []

var boardSizex: int = 10
var boardSizey: int = 22

func _ready() -> void:
	pass

func is_piece_overlapping(piece: Piece) -> bool:
	if piece.belongBoard == null:
		return false
	for block: Block in piece.blockCollection:
		var boardFocPos: Vector2i = block.boardPos
		
		if boardFocPos.x < 0: return true
		if boardFocPos.x >= boardSizex: return true
		if boardFocPos.y < 0: return true
		if boardFocPos.y > boardSizey: return true
		if blockBoard[boardFocPos.y-1][boardFocPos.x] != null:
			return true
	return false

func block_board_init() -> void:
	blockBoard = []
	for rowi: int in range(boardSizey):
		var blockRow: Array = []
		for coli: int in range(boardSizex):
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

func clear_blocks_on_rows(fullLineInds: Array) -> void:
	for rowInd: int in fullLineInds:
		for block: Block in blockBoard[rowInd]:
			%Blocks.remove_child(block)
			%BoardParticles.add_explosion(block.boardPos, PieceLookups.blockColors[block.blockColorId])
		%BoardGameState.increment_level(true)

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
	for row: int in rowsToAdd:
		var newEmptyBlockRow: Array[Block] = []
		for col: int in boardSizex:
			newEmptyBlockRow.append(null)
		blockBoard.insert(0,newEmptyBlockRow)
	
	# update positions of existing blocks to match their new positions
	for rowi: int in blockBoard.size():
		for coli: int in blockBoard[rowi].size():
			var referenceBlock: Block = blockBoard[rowi][coli]
			if blockBoard[rowi][coli] != null:
				referenceBlock.boardPos = Vector2i(coli, rowi+1)
	
	update_block_outlines()

func set_piece_to_board(piece: Piece) -> void:
	# Block Transfer
	for block: Block in piece.blockCollection:
		var setPos: Vector3 = block.global_position
		#block.position = Vector3(block.boardPos.x, -block.boardPos.y,0)
		block.get_parent().remove_child(block)
		%Blocks.add_child(block)
		var checkBlock: Block = blockBoard[block.boardPos.y-1][block.boardPos.x]
		if checkBlock != null:
			checkBlock.get_parent().remove_child(checkBlock)
			checkBlock.free()
		blockBoard[block.boardPos.y-1][block.boardPos.x] = block
		block.global_position = setPos
		block.set_placed(true)
		block.set_block_material(piece.belongBoard.locked_block_mat)
	
	linesToClear = get_full_line_inds()
	if linesToClear.size() != 0:
		clear_blocks_on_rows(linesToClear)
		%BoardGameState.set_are_line_delay()
		#areCounter = Lookups.get_line_are_delay(%BoardGameState.level)
	else:
		%BoardGameState.set_are_delay()
		#areCounter = Lookups.get_are_delay(belongBoard.level)
	#belongBoard.get_node("Pieces").add_child(make_piece(belongBoard, 1))
	piece.pieceSet = true
	piece.controllingPiece = false
	%BoardGameState.increment_level(false)
	%BoardGameState.activePiece = null
	piece.get_parent().remove_child(piece)
	piece.queue_free()
	
	update_block_outlines()
	
	#queue_free()

func special_rotation_check(location: Vector2i) -> bool:
	for rowi: int in range(3):
		for coli: int in range(3):
			var gridFoc: Vector2i = location + Vector2i(coli, rowi)
			if blockBoard[gridFoc.y-1][gridFoc.x] != null:
				if coli == 1:
					return false
				else:
					return true
	return true

func update_block_outline(block: Block, row: int, col: int) -> void:
	if block == null: return
	var dirList: Array[Vector2i] = []
	for rowi: int in range(-1, 2):
		for coli: int in range(-1, 2):
			if abs(rowi+coli) % 2 == 0: continue
			var frow: int = rowi+row
			var fcol: int = coli+col
			if frow < 0 or fcol < 0 or frow >= boardSizey or fcol >= boardSizex: continue
			var fBlock: Block = blockBoard[frow][fcol]
			# if spot on board is empty or if block is no longet in scene tree
			if fBlock == null or fBlock.get_parent()==null:
				dirList.append(Vector2i(coli,rowi))
	block.update_outline(dirList)

func update_block_outlines() -> void:
	for rowi: int in boardSizey:
		for coli: int in boardSizex:
			update_block_outline(blockBoard[rowi][coli], rowi, coli)
					
