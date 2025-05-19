extends Control
class_name BoardSelect

var gamemodeSelectionScene: PackedScene = preload("res://assets/board/BoardSelectGamemodeSelection.tscn")

var gamemodeSelectInd: int = 0
var gamemodeList: Array = []

func init_gamemode_list() -> void:
	for child: Node in %GamemodeList.get_children():
		%GamemodeList.remove_child(child)
		child.queue_free()
	for gamemode: Lookups.Gamemode in Lookups.gamemodeLookups:
		var addingGamemode: Dictionary = Lookups.gamemodeLookups[gamemode]
		var addingLabel: Label = gamemodeSelectionScene.instantiate()
		addingLabel.text = addingGamemode["modeName"]
		%GamemodeList.add_child(addingLabel)
		gamemodeList.append(addingGamemode)
	var baseOffset: float = (%GamemodeList.get_parent() as TextureRect).custom_minimum_size.y/2
	var itemOffset: float = (%GamemodeList.get_child(gamemodeSelectInd) as Label).size.y/2
	%GamemodeList.position.y = baseOffset - itemOffset
	

func _ready() -> void:
	init_gamemode_list()

func _process(delta: float) -> void:
	pass
	
