extends Node

var enemy_data    # All of the enemies in the game as JSON
var player_data    # All of the playable characters in the game as JSON
var spell_data    # All of the spells in the game as JSON
var items

# When game starts
func _ready():
	# Load the enemy data into an object
	var enemydata_file = File.new()
	enemydata_file.open("res://resources/data/enemies.json", File.READ)
	var enemydata_json = JSON.parse(enemydata_file.get_as_text())
	enemydata_file.close()
	enemy_data = enemydata_json.result
	print(enemy_data[0])
	
	# Load the player data into an object
	var playerdata_file = File.new()
	playerdata_file.open("res://resources/data/playable.json", File.READ)
	var playerdata_json = JSON.parse(playerdata_file.get_as_text())
	playerdata_file.close()
	player_data = playerdata_json.result
	print(player_data[0])
	
	# Load spell data into an object
	var spelldata_file = File.new()
	spelldata_file.open("res://resources/data/spells.json", File.READ)
	var spelldata_json = JSON.parse(spelldata_file.get_as_text())
	spelldata_file.close()
	spell_data = spelldata_json.result
	print(spell_data[0])
	
	items = preload("res://Items.tscn").instance()
