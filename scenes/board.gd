extends Node3D
class_name PlayBoard
## Contains overall board processes across a single playing game instance.

@export var gamemode: Lookups.Gamemode = Lookups.Gamemode.TADEATH

## Instance default block material for current board.
@onready var block_mat: ShaderMaterial = preload("res://scenes/materials/block.tres")

## Instance piece material for current board.
@onready var locking_block_mat: ShaderMaterial = preload("res://scenes/materials/lockingBlock.tres")

## Instance locked block material for current board.
@onready var locked_block_mat: ShaderMaterial = preload("res://scenes/materials/lockedBlock.tres")

	
func _ready() -> void:
	pass
	#add_child(Piece.makePiece(0))
	#init_play()
	#block_board_init()
	#generate_next_piece(true)
	#add_piece()

## Initializes board, calls initialization methods on subnodes.
func init_play() -> void:
	for sub: Node in %Subs.get_children():
		sub.set_physics_process(true)
		sub.set_process(true)
	%BoardGrid.block_board_init()
	%BoardGameState.board_game_state_init()
	%BoardGameState.gamemode = gamemode

func _on_ready_go_ready_go_end() -> void:
	init_play()


func update_game_mode(gamemode: Lookups.Gamemode) -> void:
	self.gamemode = gamemode
	%BoardGameState.gamemode = gamemode

func on_reset_board_button() -> void:
	print_orphan_nodes()
	board_reset()
	update_game_mode(gamemode)
	#init_play()
	%BoardGameState.generate_next_piece(true)
	for sub: Node in %Subs.get_children():
		sub.set_physics_process(false)
		sub.set_process(false)
	%Subs.get_node("Input").set_physics_process(true)
	%ReadyGo.init_ready_go()

## Main overhead processing loop.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset_board"):
		on_reset_board_button()

## Queues all playfield nodes free, removes game data that persists through subnodes.
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
	for child: Node3D in %Particles.get_children():
		%Particles.remove_child(child)
		child.queue_free()
	%BoardGameState.activePiece = null
	

# easy access methods

## Easy access method for overlapping [Piece] checks.
func is_piece_overlapping(piece: Piece) -> bool:
	return %BoardGrid.is_piece_overlapping(piece)

## Easy access method for special [Piece] rotation checks.
func special_rotation_check(location: Vector2i) -> bool:
	return %BoardGrid.special_rotation_check(location)
