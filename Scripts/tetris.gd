extends Node2D

const GridWidth := 10
const GridHeight := 20
const cellSize := 32
var grid := []

var piece

var xPlayer := 3.0
var yPlayer := 3.0
var goingdown = false


var bagPieces: Array[int] = []
var score := 0
var lines := 0
@onready var score_label = $Score
@onready var lines_label = $Lines
var gameover := false

var boxPosition = Vector2(-6, 9)
var boxPiecePosition = Vector2(-5, 10)

var nextPiece: int

@onready var song : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	
	grid.resize(GridWidth)
	for x in range(GridWidth):
		grid[x] = []
		grid[x].resize(GridHeight)
		for y in range(GridHeight):
			grid[x][y] = 0
			#
	#grid[4][7] = 3
	#grid[6][7] = 3
	#grid[5][8] = 3
	#for x in range(GridWidth - 1):
		#grid[x][19] = (randi() % 7 + 1)
		#
	#for x in range(GridWidth - 1):
		#grid[x][18] = (randi() % 7 + 1)
	#
	#for x in range(GridWidth - 1):
		#grid[x][17] = (randi() % 7 + 1)
	
	if bagPieces.is_empty():
		refillBag()
	
	spawnPiece()
	
	score_label.text = "Pontos: \n  " + str(score)
	

func _process(delta: float) -> void:
	if piece == null:
		return 
	if Input.is_action_just_pressed("direita"):
		piece.move(Vector2(1,0))
	if Input.is_action_just_pressed("esquerda"):
		piece.move(Vector2(-1,0))
	if(Input.is_action_just_pressed("baixo")):
		piece.move(Vector2(0,1))
	if(Input.is_action_just_pressed("ColocarPeca")):
		goingdown = true
		while goingdown:
			#print("checando se pode ou nao pode: ")
			if piece.move(Vector2(0,1)):
				#print("pode")
				pass
			else:
				#print("nao pode")
				piece.lockPiece(piece)
				cleanLine()
				queue_redraw() # repinta tudo
				piece.queue_free() # remove a peça antiga
				spawnPiece()
				goingdown = false
	if(Input.is_action_just_pressed("cima")):
			piece.rotate_piece()
		
func _draw() -> void:
	for x in range(GridWidth + 1):
		draw_line(Vector2(x * cellSize,0), Vector2(x * cellSize, GridHeight * cellSize),Color.WHITE, 1.5)
	
	for y in range(GridHeight +1):
		draw_line(Vector2(0, y * cellSize), Vector2(GridWidth * cellSize, y * cellSize), Color.GRAY, 1.5)
		
	for x in range(GridWidth):
		for y in range(GridHeight):
			if grid[x][y] == 0:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 2,cellSize - 2)),Color(1, 0, 0, 0))
			elif grid[x][y] == 1:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color.CYAN)
			elif grid[x][y] == 2:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color.WEB_PURPLE)
			elif grid[x][y] == 3:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color.RED)
			elif grid[x][y] == 4:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color.LIGHT_GREEN)
			elif grid[x][y] == 5:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color.YELLOW)
			elif grid[x][y] == 6:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color.ORANGE)
			elif grid[x][y] == 7:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color.DARK_BLUE)
			elif grid[x][y] == 8:
				draw_rect(Rect2(Vector2(x,y) * cellSize, Vector2(cellSize - 1,cellSize - 1)),Color("031b24"))
	
	var preview_box = Rect2(boxPosition * cellSize, Vector2((cellSize * 4) + 30, (cellSize * 4)))
	draw_rect(preview_box, Color(0.1, 0.1, 0.1), true) # Fundo escuro
	draw_rect(preview_box, Color.WHITE, false, 2.0)
	
	for block in piece.blocks:
		var x = (boxPosition.x + block.x) * cellSize
		var y = (boxPosition.y + block.y) * cellSize
		
		var colorNum = piece.num
		var color
		match colorNum:
			1:
				color = Color.CYAN
				draw_rect(Rect2(Vector2(x + 50, y + 45), Vector2(cellSize - 2, cellSize - 2)), color)
			2:
				color = Color.WEB_PURPLE
				draw_rect(Rect2(Vector2(x + 65, y + 65), Vector2(cellSize - 2, cellSize - 2)), color)
			3:
				color = Color.RED
				draw_rect(Rect2(Vector2(x + 80, y + 50), Vector2(cellSize - 2, cellSize - 2)), color)
			4:
				color = Color.LIGHT_GREEN
				draw_rect(Rect2(Vector2(x + 65, y + 30), Vector2(cellSize - 2, cellSize - 2)), color)
			5:
				color = Color.YELLOW
				draw_rect(Rect2(Vector2(x + 50, y + 30), Vector2(cellSize - 2, cellSize - 2)), color)
			6:
				color = Color.ORANGE
				draw_rect(Rect2(Vector2(x + 65, y + 40), Vector2(cellSize - 2, cellSize - 2)), color)
			7:
				color = Color.DARK_BLUE
				draw_rect(Rect2(Vector2(x + 65, y + 40), Vector2(cellSize - 2, cellSize - 2)), color)
			8: 
				color = Color("031b24")
				draw_rect(Rect2(Vector2(x + 50, y + 40), Vector2(cellSize - 2, cellSize - 2)), color)
		
		#draw_rect(Rect2(Vector2(x + 50, y + 40), Vector2(cellSize - 2, cellSize - 2)), color)

func spawnPiece():
	print(bagPieces)
	if bagPieces.is_empty():
		refillBag()
		print("ta enchendokkkkkk")
	print(bagPieces)
	var num = bagPieces.pop_back()
	print(num)
	#print("numero da cor:", num)
	var startPos = Vector2(GridWidth / 2 - 1, 1)
	piece = Piece.new(startPos, num)
	
	if isSpawnBlocked(piece.blocks, startPos):
		triggerGameOver()
		piece.queue_free()
		return
	#piece.main_script = self
	else:
		add_child(piece)
	#return piece
	
func cleanLine():
	
	var y = GridHeight - 1
	var linesScores = 0
	while y >= 0: # de baixo pra cima
		var isFull = true
		for x in range(GridWidth):
			if grid[x][y] == 0:
				isFull = false
				break
		if isFull:
			removeLine(y)
			linesScores += 1
			lines += 1
		else:
			y -= 1 #checa toda a linhas de baixo pra cima
	updateScore(linesScores)
	
	linesScores = 0

		

func removeLine(lineY: int):
	for y in range(lineY, 0, -1):
		for x in range(GridWidth):
			grid[x][y] = grid[x][y - 1]
	# limpa em cima
	for x in range(GridWidth):
		grid[x][0] = 0
		
func updateScore(numlines: int):
	match numlines:
		1:
			score += 100
		2: 
			score += 300
		3: 
			score += 500
		4: 
			score += 800
	score_label.text = "Pontos: \n  " + str(score)
	lines_label.text = "Lines: " + str(lines)
	
func triggerGameOver():
	gameover = true
	$Timer.stop()
	score_label.text = "Pontos: \n  " + str(score) + " \n------------\n GAME OVER"
	for x in range(GridWidth):
		for y in range(GridHeight):
			if grid[x][y] > 0:
				grid[x][y] = 8

func isSpawnBlocked(piece: Array[Vector2], spawnPos: Vector2) -> bool:
	for block in piece:
		var x = int(spawnPos.x + block.x)
		var y = int(spawnPos.y + block.y)
	
		if x >= 0 and x < GridWidth and y >= 0 and y < GridHeight:
			if grid[x][y] != 0:
				return true
		
	return false

func refillBag():
	bagPieces.append(1)
	bagPieces.append(2)
	bagPieces.append(3)
	bagPieces.append(4)
	bagPieces.append(5)
	bagPieces.append(6)
	bagPieces.append(7)
	
	randomize()
	bagPieces.shuffle()
	
	
	
	
	

	


func _on_audio_stream_player_finished() -> void:
	#song.play()
	pass
