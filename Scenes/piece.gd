extends Node2D
class_name Piece

var color: Color
var blocks: Array[Vector2]
var gridPosition: Vector2 
var num

var main_script: Node2D

const cellSize = 32

var checkFall = 0

const KICKS_NORMAL = [
	[Vector2(0,0), Vector2(-1,0), Vector2(-1,-1), Vector2(0,2), Vector2(-1,2)], # 0 -> 1
	[Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,-2), Vector2(1,-2)],    # 1 -> 2
	[Vector2(0,0), Vector2(1,0), Vector2(1,-1), Vector2(0,2), Vector2(1,2)],    # 2 -> 3
	[Vector2(0,0), Vector2(-1,0), Vector2(-1,1), Vector2(0,-2), Vector2(-1,-2)] # 3 -> 0
]

const KICKS_I = [
	[Vector2(0,0), Vector2(-2,0), Vector2(1,0), Vector2(-2,1), Vector2(1,-2)],  # 0 -> 1
	[Vector2(0,0), Vector2(-1,0), Vector2(2,0), Vector2(-1,-2), Vector2(2,1)],  # 1 -> 2
	[Vector2(0,0), Vector2(2,0), Vector2(-1,0), Vector2(2,-1), Vector2(-1,2)],  # 2 -> 3
	[Vector2(0,0), Vector2(1,0), Vector2(-2,0), Vector2(1,2), Vector2(-2,-1)]   # 3 -> 0
]

var current_rotation = 0

const iP: Array[Vector2] = [
	Vector2(-1, 0),
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(2, 0)
]

const sP: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 1)
]

const zP: Array[Vector2] = [
	Vector2(0,-1), 
	Vector2(0,0),
	Vector2(-1,0),
	Vector2(-1,1)
]

const tP: Array[Vector2] = [
	Vector2(-1,0),
	Vector2(0,0),
	Vector2(1,0),
	Vector2(0,-1)
]

const oP: Array[Vector2] = [
	Vector2(0,0),
	Vector2(0,1),
	Vector2(1,0),
	Vector2(1,1),
]

const lP: Array[Vector2] = [
	Vector2(-1, 0),
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(1, 1)
]

const jP: Array[Vector2] = [
	Vector2(-1, 0),
	Vector2(0, 0),
	Vector2(1, 0),
	Vector2(-1, 1)
]

const allPieces: Array = [iP, sP, zP, tP, oP, lP, jP]
var ghostPosition: Vector2
var ghostBlocks: Array[Vector2]


func _init(igridPosition : Vector2 = Vector2.ZERO, iNumber : int = 0):
	
	gridPosition = igridPosition
	ghostPosition = igridPosition
	num = iNumber
	
	if(num == 1):
		blocks = iP
		color = Color.CYAN
	elif(num == 2):
		blocks = tP
		color = Color.WEB_PURPLE
	elif(num == 3):
		blocks = zP
		color = Color.RED
	elif(num == 4):
		blocks = sP
		color = Color.LIGHT_GREEN
	elif(num == 5):
		blocks = oP
		color = Color.YELLOW
	elif(num == 6):
		blocks = lP
		color = Color.ORANGE
	elif(num == 7):
		blocks = jP
		color = Color.DARK_BLUE
	
	ghostBlocks = blocks
	#print(ghostBlocks)


func _ready() -> void:
	
	main_script = get_node("/root/Tetris")
	var timer := $"../Timer"
	updateGhostPosition()
	#add_child(timer)
	timer.timeout.connect(fall)
	timer.autostart = true
	timer.wait_time = 0.5
	timer.start(1)

func _draw() -> void:
	
	for ghostBlock in ghostBlocks:
		var x = (ghostPosition.x + ghostBlock.x) * cellSize
		var y = (ghostPosition.y + ghostBlock.y) * cellSize
		
		var ghostColor = Color(0.39215687, 0.58431375, 0.92941177, 0.7)
		draw_rect(Rect2(Vector2(x, y), Vector2(cellSize, cellSize)), ghostColor, true)
	
	for block in blocks:
		draw_rect(Rect2((block + gridPosition) * cellSize, Vector2(cellSize - 2, cellSize - 2)), color, true)

func move(direction: Vector2):
	var new_position = gridPosition + direction
	if isValidmove(new_position):
		gridPosition = new_position
		queue_redraw()
		updateGhostPosition()
		return true
	else:
		return false

func fall():
	#print("checkfall: ", checkFall)
	if not move(Vector2(0,1)):
		checkFall += 1
		if checkFall >= 2:
			lockPiece(self)
			main_script.cleanLine()
			main_script.queue_redraw()
			main_script.spawnPiece()
			queue_free()
			checkFall = 0

func _process(_delta: float) -> void:
	pass

func lockPiece(piece: Piece):
	for block in piece.blocks:
		var x = int(piece.gridPosition.x + block.x)
		var y = int(piece.gridPosition.y + block.y)
		if x >= 0 and x < main_script.GridWidth and y >= 0 and y < main_script.GridHeight:
			main_script.grid[x][y] = piece.num
		#elif x >= 0 and x < main_script.GridWidth and y >= 0 and y < main_script.GridHeight and num == 1:
			#main_script.grid[x][y] = 7
		queue_redraw()

func rotate_piece() -> Array[Vector2]:
	if num == 5: return blocks
	#print(current_rotation)
	var rotated_blocks: Array[Vector2] = []
	#print("entrando no rotacionar")
	for block in blocks:
		var new_block: Vector2
		new_block = Vector2(-block.y, block.x) 
		rotated_blocks.append(new_block) 
	#print("rotacionou")
	
	var kickTable = KICKS_NORMAL if num == 1 else KICKS_I
	var tests = kickTable[current_rotation]
	
	for rotation in tests:
		var testPos = gridPosition + rotation
		if isValidmove(testPos, rotated_blocks):
			#print("foi...")
			gridPosition = testPos
			blocks = rotated_blocks
			current_rotation = (current_rotation + 1) % 4
			queue_redraw()
			updateGhostPosition()
			return rotated_blocks
	updateGhostPosition()
	return blocks

func isValidmove(target_position: Vector2, target_blocks: Array[Vector2] = []) -> bool:
	if target_blocks.is_empty():
		target_blocks = blocks
	if not main_script:
		return true
	
	for block in target_blocks: 
		var absolute_pos = block + target_position
		var x = int(absolute_pos.x)
		var y = int(absolute_pos.y)
		
		# Checar Limites Horizontais e Verticais
		if x < 0 or x >= main_script.GridWidth:
			return false
		#print("Y: " + str(y) + "GridHeight: " + str(main_script.GridHeight))
		if y < 0 or y >= main_script.GridHeight:
			return false
		
		# Checar se a célula já está ocupada
		if main_script.grid[x][y] != 0:
			return false
	return true
	
func updateGhostPosition():
	if not main_script:   # sai se ainda não conectou
		return
	if blocks.is_empty(): # sai se a peça ainda não foi inicializada
		return
	var testPosition = gridPosition
	ghostBlocks = blocks
	var ghostFalling = true
	
	while ghostFalling:
		if isValidmove(testPosition + Vector2(0,1), ghostBlocks):
			testPosition += Vector2(0,1)
		else:
			ghostFalling = false
		
		#print(isValidmove(testPosition + Vector2(0,1), ghostBlocks))
	
	ghostPosition = testPosition
	queue_redraw()
	
