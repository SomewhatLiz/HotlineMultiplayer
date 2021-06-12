extends Node2D

onready var walls : TileMap = $Buildings/Walls

var glassRes := preload("res://Scenes/Glass/Glass.tscn")

#TileMap



func convertGlass():
	var glassTiles = walls.get_used_cells_by_id(3)
	for tile in glassTiles:
		instanceGlass(
			walls.map_to_world(tile), 
			walls.is_cell_x_flipped(tile.x, tile.y), 
			walls.is_cell_x_flipped(tile.x, tile.y), 
			walls.is_cell_transposed(tile.x, tile.y)
		)
		walls.set_cellv(tile, -1)
		
#Position is in global space
func instanceGlass(pos, xFlipped, yFlipped, transposed):
	var glass = glassRes.instance()
	if xFlipped:
		glass.rotation += PI
	if yFlipped:
		glass.flipSprite()
	if transposed:
		glass.rotation -= PI/2
	glass.position = pos + Vector2(16, 16)
	$Buildings.add_child(glass)

func _ready():
	convertGlass()
