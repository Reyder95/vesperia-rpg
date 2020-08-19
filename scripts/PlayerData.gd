extends Node

var char1 = preload("res://entities/Playable.tscn").instance()

func _ready():
	
	char1.add_child(preload("res://resources/Animations/Playable/Ryuko.tscn").instance())
	
	load_stats(char1, 0)

func load_stats(character, index):
	character.level = 99
	character.char_name = LoadData.player_data[index].name
	character.maximum_health = 100 + ((character.level - 1) * 25)
	character.current_health = character.maximum_health
	character.attack = 50 + ((character.level - 1) * 10)
	character.strength = LoadData.player_data[index].strength_multiplier * (100 + ((character.level - 1) * 25))
	character.dexterity = LoadData.player_data[index].dexterity_multiplier * (100 + ((character.level - 1) * 25))
	character.intelligence = LoadData.player_data[index].intelligence_multiplier * (100 + ((character.level - 1) * 25))
	character.armor = LoadData.player_data[index].armor_multiplier * (5 + ((character.level - 1) * 2) + character.strength)
	
