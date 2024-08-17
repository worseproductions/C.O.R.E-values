class_name TileMapInfection
extends TileMapLayer

@export var core_tile_coords: Vector2
@export var infection_chance = 0.8

@export_group("Infected Tile")
@export var infected_tile_tileset: int
@export var infected_tile_coords: Vector2
@export var infected_tile_alt: int

@onready var game_manager: GameManager = $"/root/GameManager"

var latest_infected_tiles: Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.update_killcount.connect(_on_update_killcount)
	spread_core()

func _on_update_killcount(kills_to_next_infection, kills):
	if kills >= kills_to_next_infection:
		game_manager.next_level()
		spread_core()

func spread_core():
	if latest_infected_tiles.is_empty():
		infect_neighbors(core_tile_coords)
	else:
		var tiles = latest_infected_tiles
		latest_infected_tiles = []
		for coords in tiles:
			infect_neighbors(coords)


func infect_neighbors(coords: Vector2):
	var neighbors = get_surrounding_cells(coords)
	for cell_coords: Vector2 in neighbors:
		if (randf() <= infection_chance):
			if (cell_coords == core_tile_coords):
				continue
			set_cell(cell_coords, infected_tile_tileset, infected_tile_coords, infected_tile_alt)
			latest_infected_tiles.append(cell_coords)
