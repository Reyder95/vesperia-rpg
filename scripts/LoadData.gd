extends Node

var enemy_data

func _ready():
	var enemydata_file = File.new()
	enemydata_file.open("res://resources/data/enemies.json", File.READ)
	var enemydata_json = JSON.parse(enemydata_file.get_as_text())
	enemydata_file.close()
	enemy_data = enemydata_json.result
	print(enemy_data[0])
