extends Node2D

var players = Array()    # Array of the entire set of players
var enemies = Array()    # Array of the entire set of enemies

var player_turn_order = Array()    # The current queue of turns that will go through for players 
var enemy_turn_order = Array()    # The current queue of turns that will go through for enemies

var current_state = null    # The current state of the battle

# Set of nodes that will be used during the battle
onready var interface = $UI/BottomPanel/BattleUI    # The battle interface that will be shown and hidden depending on who's turn it is
onready var right_side = $BattleRight    # The right side of entities in the battle
onready var right_side_hp = $UI/RightHP    # The 
onready var left_side = $BattleLeft
onready var left_side_hp = $UI/LeftHP
onready var state_label = $UI/State

enum STATES {
	PLAYER,
	ENEMY,
	WIN,
	LOSE
}

func _ready():
	
	for i in range(0, LoadData.enemy_data.size()):
		var enemy = LoadData.enemy_data[i]
		var enemy_scene = load("res://entities/Enemy.tscn").instance()
		var file_name = enemy.name + ".tscn"
		var animation = load("res://resources/Animations/Enemies/" + file_name)
		
		if animation != null:
			enemy_scene.add_child(animation.instance())
			
			load_stats(enemy_scene, enemy)
	
	for i in range(0, players.size()):
		var player = players[i]
		
		right_side.get_children()[i].add_child(player)
		
		right_side.get_children()[i].get_children()[0].get_node("AnimatedSprite").set_flip_h(true)
		right_side_hp.get_node("pos" + str(i+1)).show()
		right_side_hp.get_node("pos" + str(i+1)).text = "Health: " + str(player.current_health) + "/" + str(player.maximum_health)
		
	for i in range(0, enemies.size()):
		var enemy = enemies[i]
		
		left_side.get_children()[i].add_child(enemy)
		
		left_side_hp.get_node("pos" + str(i+1)).show()
		left_side_hp.get_node("pos" + str(i+1)).text = "Health: " + str(enemy.current_health) + "/" + str(enemy.maximum_health)

		current_state = STATES.PLAYER
		handle_states()

func load_stats(scene, enemy_object):
	scene.maximum_health = enemy_object.max_health
	scene.current_health = scene.maximum_health
	scene.level = enemy_object.level
	scene.char_name = enemy_object.name
	
	scene.attack = enemy_object.attack
	scene.armor = enemy_object.armor
	scene.strength = enemy_object.stats.strength
	scene.dexterity = enemy_object.stats.dexterity
	scene.intelligence = enemy_object.stats.intelligence
	
	scene.print_stats()
	print("")

func handle_states():
	match current_state:
		STATES.PLAYER:
			state_label.text = "Player"
			player_turn_order = players.duplicate()
			interface.show()
		STATES.ENEMY:
			state_label.text = "Enemy"
			enemy_turn_order = enemies.duplicate()
			_handle_enemy_turn()
			interface.hide()
			
func _handle_damage_dealt(attacker, target, number, side):
	attacker._attack_entity(target)
	if side == "right":
		right_side_hp.get_node("pos" + str(number)).text = "Health: " + str(target.current_health) + "/" + str(target.maximum_health)
	elif side == "left":
		print("pos" + str(number))
		left_side_hp.get_node("pos" + str(number)).text = "Health: " + str(target.current_health) + "/" + str(target.maximum_health)
			
func _handle_player_turn(choice):
	match choice:
		"attack":
			var randomTarget = randi() % enemies.size()
			_handle_damage_dealt(player_turn_order[0], enemies[randomTarget], randomTarget+1, "left")
			player_turn_order.pop_front()
			print(player_turn_order)
			if player_turn_order.size() <= 0:
				current_state = STATES.ENEMY
				handle_states()

func _handle_enemy_turn():
	while enemy_turn_order.size() > 0:
		yield(get_tree().create_timer(1.0), "timeout")
		var randomTarget = randi() % players.size()
		_handle_damage_dealt(enemy_turn_order[0], players[randomTarget], randomTarget+1, "right")
		enemy_turn_order.pop_front()
		print(enemy_turn_order)
	
	current_state = STATES.PLAYER
	handle_states()
func _on_Attack_pressed():
	_handle_player_turn("attack")
