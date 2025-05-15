extends Node

const defaultLookups: Dictionary = {
	"areThresh" : [700, 800, 999],
	"areVals" : [27, 18, 14],
	"lineAreThresh" : [600, 700, 800, 999],
	"lineAreVals" : [27, 18, 14, 8],
	"dasThresh" : [500, 900, 999],
	"dasVals" : [16, 10, 8],
	"lockThresh" : [900, 999],
	"lockVals" : [30, 17],
	"lineClearThresh" : [500, 600, 700, 800, 999],
	"lineClearVals" : [40, 25, 16, 12, 6],
	"gravThresh" : [
		0,  30 ,35 ,40 ,
		50 ,60 ,70 ,80 ,
		90,100,120,140,
		160,170,200,220,
		230,233,236,239,
		243,247,251,300,
		330,360,400,420,450,500
	],
	"gravVals" : [
		4  ,6  ,8  ,10 ,
		12 ,16 ,32 ,48 ,
		64 ,80 ,96 ,112,
		128,144,4  ,32 ,
		64 ,96 ,128,160,
		192,224,256,512,
		768,1024,1280,1024,768,5120
	]
}

const masterLookups: Dictionary = {
	
}

const normalLookups: Dictionary = {
	
}

const tadeathLookups: Dictionary = {
	
}

const shiraseLookups: Dictionary = {
	
}

const twentygLookups: Dictionary = {
	
}

const bigLookups: Dictionary = {
	
}

const gamemodeLookups: Dictionary[int, Dictionary] = {
	Gamemodes.Mode.DEFAULT : defaultLookups,
	Gamemodes.Mode.MASTER : masterLookups,
	Gamemodes.Mode.NORMAL : normalLookups,
	Gamemodes.Mode.TADEATH : tadeathLookups,
	Gamemodes.Mode.SHIRASE : shiraseLookups,
	Gamemodes.Mode.TWENTYG : twentygLookups,
	Gamemodes.Mode.BIG : bigLookups,
} 

#const areThresh: Array = [
	#700, 800, 999
#]

#const areVals: Array = [
	#27, 18, 14
#]

#const lineAreThresh: Array = [
	#600, 700, 800, 999
#]

#const lineAreVals: Array = [
	#27, 18, 14, 8
#]

#const dasThresh: Array = [
	#500, 900, 999
#]

#const dasVals: Array = [
	#16, 10, 8
#]

#const lockThresh: Array = [
	#900, 999
#]

#const lockVals: Array = [
	#30, 17
#]

#const lineClearThresh: Array = [
	#500, 600, 700, 800, 999
#]

#const lineClearVals: Array = [
	#40, 25, 16, 12, 6
#]

#const gravThresh: Array = [
	#0,  30 ,35 ,40 ,
	#50 ,60 ,70 ,80 ,
	#90,100,120,140,
	#160,170,200,220,
	#230,233,236,239,
	#243,247,251,300,
	#330,360,400,420,450,500
#]

#const gravVals: Array = [
	#4  ,6  ,8  ,10 ,
	#12 ,16 ,32 ,48 ,
	#64 ,80 ,96 ,112,
	#128,144,4  ,32 ,
	#64 ,96 ,128,160,
	#192,224,256,512,
	#768,1024,1280,1024,768,5120
#]

# line are delay when no lines are cleared
func get_are_delay(level: int, gamemode: int) -> int:
	return get_val_from_mode_table(level, "are", gamemode)

# the initial line are delay used when a line is cleared, before pieces drop
func get_line_are_delay(level: int, gamemode: int) -> int:
	return get_val_from_mode_table(level, "lineAre", gamemode)

# the following line are delay used when a line is cleared, while pieces drop
func get_line_clear_are_delay(level: int, gamemode: int) -> int:
	return get_val_from_mode_table(level, "lineClear", gamemode)
	
func get_das_delay(level: int, gamemode: int) -> int:
	return get_val_from_mode_table(level, "das", gamemode)

func get_gravity(level: int, gamemode: int) -> int:
	return get_val_from_mode_table(level, "grav", gamemode)

func get_lock_delay(level: int, gamemode: int) -> int:
	return get_val_from_mode_table(level, "lock", gamemode)


func get_val_from_mode_table(level: int, type: String, gamemode: int) -> int:
	var gamemodeLookup: Dictionary = gamemodeLookups[gamemode]
	var typeThresh: Array = gamemodeLookup.get(type+"Thresh", [])
	var typeVals: Array = gamemodeLookup.get(type+"Vals", [])
	if typeThresh.size()!=0 and typeVals.size()!=0 and typeThresh.size() == typeVals.size():
		return get_val_from_table(level, typeThresh, typeVals)
	else:
		typeThresh = gamemodeLookups[Gamemodes.Mode.DEFAULT].get(type+"Thresh")
		typeVals = gamemodeLookups[Gamemodes.Mode.DEFAULT].get(type+"Vals")
		return get_val_from_table(level, typeThresh, typeVals)


func get_val_from_table(amnt: int, target: Array, returnVal: Array) -> int:
	for i: int in range(target.size()-1, -1, -1):
		#print(target[i])
		if target[i] <= amnt:
			return returnVal[i]
	return returnVal.front()
