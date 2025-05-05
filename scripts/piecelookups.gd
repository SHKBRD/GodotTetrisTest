extends Resource

var blockShapes: Array[Array] = [
	# O
	[
		[Vector2i(1, 1),Vector2i(2, 1), Vector2i(1, 2), Vector2i(2, 2)]
	],
	# J
	[
		[Vector2i(0, 1),Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],
		[Vector2i(1, 0),Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
		[Vector2i(0, 1),Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
		[Vector2i(1, 0),Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
	],
	# L
	[
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],
		[Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
	],
	# Z
	[
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
		[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
	],
	# S
	[
		[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
	],
	# T
	[
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
		[Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
	],
	# I
	[
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
		[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
	]
]

var blockColors: Array[Color] = [
	Color.from_rgba8(255,255,0),
	Color.from_rgba8(0,0,255),
	Color.from_rgba8(255,170,255),
	Color.from_rgba8(255,0,255),
	Color.from_rgba8(0,255,0),
	Color.from_rgba8(0,255,255),
	Color.from_rgba8(255,0,0),
]
