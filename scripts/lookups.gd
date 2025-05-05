extends Node

const areThresh: Array = [
	700, 800, 999
]

const areVals: Array = [
	27, 18, 14
]

const lineAreThresh: Array = [
	600, 700, 800, 999
]

const lineAreVals: Array = [
	27, 18, 14, 8
]

const dasThresh: Array = [
	500, 900, 999
]

const dasVals: Array = [
	16, 10, 8
]

const lockThresh: Array = [
	900, 999
]

const lockVals: Array = [
	30, 17
]

const lineClearThresh: Array = [
	500, 600, 700, 800, 999
]

const lineClearVals: Array = [
	40, 25, 16, 12, 6
]

# line are delay when no lines are cleared
func get_are_delay(level: int) -> int:
	return get_val_from_table(level, areThresh, areVals)

# the initial line are delay used when a line is cleared, before pieces drop
func get_line_are_delay(level: int) -> int:
	return get_val_from_table(level, lineAreThresh, lineAreVals)

# the following line are delay used when a line is cleared, while pieces drop
func get_line_clear_are_delay(level: int) -> int:
	return get_val_from_table(level, areThresh, areVals)
	
func get_das_delay(level: int) -> int:
	return get_val_from_table(level, dasThresh, dasVals)

func get_val_from_table(amnt: int, target: Array, returnVal: Array):
	for i in range(target.size()-1, -1, -1):
		print(target[i])
		if target[i] < amnt:
			return returnVal[i]
	return returnVal.front()
