class_name TileMapInfection
extends Node2D

@export var core_tile_coords: Vector2
@export var infection_chance = 0.8
@export var iterations_per_level = 1

@export_group("Infected Tile")
@export var infected_tile_tileset: int
@export var infected_tile_coords: Vector2
@export var infected_tile_alt: int

@onready var floor_tiles: TileMapLayer = $TileMapLayer_Floor
@onready var fog_tiles: TileMapLayer = $TileMapLayer_Fog

var latest_infected_tiles: Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.update_killcount.connect(_on_update_killcount)
	spread_core()

func _on_update_killcount(kills, kills_to_next_infection):
	if kills >= kills_to_next_infection:
		GameManager.next_level()
		spread_core()

func spread_core():
	if latest_infected_tiles.is_empty():
		infect_neighbors(core_tile_coords)
	else:
		var tiles = latest_infected_tiles
		latest_infected_tiles = []
		for coords in tiles:
			await get_tree().create_timer(0.1).timeout
			infect_neighbors(coords)


func infect_neighbors(coords: Vector2):
	var neighbors = floor_tiles.get_surrounding_cells(coords)
	for cell_coords: Vector2 in neighbors:
		if (randf() <= infection_chance):
			if (cell_coords == core_tile_coords):
				continue
			await get_tree().create_timer(0.1).timeout
			floor_tiles.set_cell(cell_coords, infected_tile_tileset, infected_tile_coords, infected_tile_alt)
			latest_infected_tiles.append(cell_coords)
