extends Node3D
class_name LevelCounter

var displayLevel: int = 0
var displaySection: int = 0


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	
func update_level_counter(level: int, section: int) -> void:
	displayLevel = level
	var levelText: String = str(level).lpad(3, "0")
	%Level.text = levelText
	displaySection = section*100 + 100
	if section == 9:
		displaySection = 999
	var sectionText: String = str(displaySection).lpad(3, "0")
	%Section.text = sectionText
	
