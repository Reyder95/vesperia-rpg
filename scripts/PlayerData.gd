extends Node

var char1 = preload("res://entities/Playable.tscn").instance()
var char2 = preload("res://entities/Playable.tscn").instance()    # DEBUG: First character initialize as "Playable" scene
var save_game_data

# When game starts
func _ready():
	
	# Add child 
	char1.add_child(preload("res://resources/Animations/Playable/Ryuko.tscn").instance())
	char2.add_child(preload("res://resources/Animations/Playable/Ryuko.tscn").instance())
	load_data()
	load_stats(char1, 0)
	load_stats(char2, 0)
	


func load_stats(character, index):
	character.level = save_game_data.characters[0].level
	character.level = 1    # Character level override
	character.char_name = LoadData.player_data[index].name
	character.maximum_health = 100 + ((character.level - 1) * 25)
	character.current_health = save_game_data.characters[0].current_health
	character.attack = 50 + ((character.level - 1) * 10)
	character.strength = LoadData.player_data[index].strength_multiplier * (10 + ((character.level - 1) * 25))
	character.dexterity = LoadData.player_data[index].dexterity_multiplier * (10 + ((character.level - 1) * 25))
	character.intelligence = LoadData.player_data[index].intelligence_multiplier * (10 + ((character.level - 1) * 25))
	character.armor = LoadData.player_data[index].armor_multiplier * (5 + ((character.level - 1) * 2) + character.strength)
	character.magicka = character.intelligence + ((character.level - 1) * 2)
	
func load_data():
	var save_dict = {
		"characters": [
			{
				"name": "Ryuko",
				"level": 1,
				"current_health": 100
			}
		]
	}
	
	var save_game = File.new()
	
	if not save_game.file_exists("user://savegame.save"):
		save_game.open("user://savegame.save", File.WRITE)
		save_game.store_line(to_json(save_dict))
		save_game.close()
		
	save_game.open("user://savegame.save", File.READ)
	save_game_data = JSON.parse(save_game.get_as_text()).result
	save_game.close()
	
func save_data():
	var save_dict = {
		"characters": [
			{
				"name": "Ryuko",
				"level": char1.level,
				"current_health": char1.current_health
			}
		]
	}
	
	var save_game = File.new()
	
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save_dict))
	save_game.close()
