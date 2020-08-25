extends Node2D

var players = Array()    # Array of the entire set of players
var enemies = Array()    # Array of the entire set of enemies

var player_turn_order = Array()    # The current queue of turns that will go through for players 
var enemy_turn_order = Array()    # The current queue of turns that will go through for enemies

var current_state = null    # The current state of the battle

# Set of nodes that will be used during the battle
onready var interface = $UI/BottomPanel/BattleUI    # The battle interface that will be shown and hidden depending on who's turn it is
onready var right_side = $BattleRight    # The right side of entities in the battle
onready var right_side_hp = $UI/RightHP    # The health for the right side of entities
onready var left_side = $BattleLeft    # The left side of entities in the battle
onready var left_side_hp = $UI/LeftHP    # The health for the left side of entities
onready var spell_panel = $UI/SpellPanel
onready var state_label = $UI/State    # DEBUG: Displays state on screen
onready var choose_enemy_panel = $UI/ChooseEnemyPanel
onready var choose_enemy = $UI/ChooseEnemyPanel/ChooseEnemy    # Choose Enemy Dialogue

var player_spells = Array()

var player_attack_choice
var player_spell_choice

# All of the possible states that the battle can enter
enum STATES {
	PLAYER,
	ENEMY,
	WIN,
	LOSE,
	RUN
}

# Initialize the battle
func _ready():

	player_spells = preload("res://Spells.tscn").instance()
	
	# DEBUG: Just pushes one playable character, will be adjusted to support all the playable characters
	players.push_back(PlayerData.char1)
	players.push_back(PlayerData.char2)
	
	# Generate the enemies that will be used in the battle.
	for i in range(0, LoadData.enemy_data.size()):
		var enemy = LoadData.enemy_data[i]    # Set the current enemy we are working with to just "enemy"
		var enemy_scene = load("res://entities/Enemy.tscn").instance()    # Load an instance of the "enemy" scene
		var file_name = enemy.name + ".tscn"    # The file for the animations of the enemy
		var animation = load("res://resources/Animations/Enemies/" + file_name)    # Use the file name to load the animation information for that enemy
		
		# If we find a proper file, add that animation as a child
		if animation != null:
			enemy_scene.add_child(animation.instance())
			
		
		load_stats(enemy_scene, enemy)    # Load the stats of the current enemy
			
		enemies.push_back(enemy_scene)    # Push the set up scene into the enemies array
	
	# Set up the players in our player array into the scene
	for i in range(0, players.size()):
		var player = players[i]    # Set the current player as "player"
		
		right_side.get_children()[i].add_child(player)    # Set the player at the proper position on the right side
		
		# Handle animations. Because right side, flip animation horizontally. Also make sure the player is playing their "idle" animation
		right_side.get_children()[i].get_children()[0].get_node("AnimatedSprite").set_flip_h(true)
		right_side.get_children()[i].get_children()[0].get_node("AnimatedSprite").play("idle")
		
		# Set up the HP UI for each player. Show it, then set it correctly
		right_side_hp.get_node("pos" + str(i+1)).show()
		right_side_hp.get_node("pos" + str(i+1)).text = str(player.current_health) + "/" + str(player.maximum_health)
		right_side_hp.get_node("pos" + str(i+1)).get_children()[0].text = player.char_name
		
		player.print_stats()    # DEBUG: Just display stats to the console
		
	# Set up the enemies in our enemy array into the scene
	for i in range(0, enemies.size()):
		var enemy = enemies[i]    # Set the current enemy as "enemy"
		
		left_side.get_children()[i].add_child(enemy)    # Set the enemy at the proper position on the left side
		
		# Handle animation. Make sure the enemy animations start at "idle"
		left_side.get_children()[i].get_children()[0].get_node("AnimatedSprite").play("idle")
		
		# Set the left side's HP UI
		left_side_hp.get_node("pos" + str(i+1)).show()
		left_side_hp.get_node("pos" + str(i+1)).text = str(enemy.current_health) + "/" + str(enemy.maximum_health)
		
		choose_enemy.add_icon_item(load("res://resources/spell_icons/Fireball.png"), enemies[i].char_name)
		choose_enemy.set_item_metadata(i, i)
		
	for i in range(0, LoadData.spell_data.size()):
		spell_panel.get_node("Spells").add_item( LoadData.spell_data[i].name, load("res://resources/spell_icons/" + LoadData.spell_data[i].name + ".png"))
		spell_panel.get_node("Spells").set_item_tooltip_enabled(i, true)
		spell_panel.get_node("Spells").set_item_tooltip(i, LoadData.spell_data[i].description)
		spell_panel.get_node("Spells").set_item_metadata(i, LoadData.spell_data[i].id)
		
	current_state = STATES.PLAYER    # Set the current state as PLAYER
	handle_states()    # Do things based on the current state
	
func _process(delta):
	if Input.is_action_pressed("ui_down"):
		PlayerData.save_data()
		print("Saved!")
		

# Load the stats of the enemy
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
	
	
	scene.print_stats()    # DEBUG: Print stats to see if things worked
	print("")   # Print an extra line to separate

# Check what the state is, and do something different
func handle_states():
	match current_state:
		
		# For PLAYER state
		STATES.PLAYER:
			state_label.text = "Player"    # Change "State" to "Player"
			player_turn_order = players.duplicate()    # Set the player turn order
			interface.show()    # Show the interface so the player can interact with it
			
		# For ENEMY state
		STATES.ENEMY:
			state_label.text = "Enemy"    # Change "State" to "Enemy"
			enemy_turn_order = enemies.duplicate()    # Set the enemy turn order
			_handle_enemy_turn()    # Handle the enemy turn
			interface.hide()    # Hide the interface

# When someone does damage, this is the function that is called
func _handle_damage_dealt(attacker, target, number, side, type):
	
	if type == "attack":
		attacker._attack_entity(target)    # Make the attacker attack the target
	
	if target.current_health == 0:
		if current_state == STATES.PLAYER:
			_handle_enemy_choice_render()
	
	# Use side to determine which side to modify the HP
	_update_health(side, number, target)

# When the player does their turn
func _handle_player_turn(choice, target_index):
	match choice:
		"attack":
			# Handle attacking animations
			player_turn_order[0].get_node("AnimatedSprite").play("attack")
			yield(player_turn_order[0].get_node("AnimatedSprite"), "animation_finished")
			player_turn_order[0].get_node("AnimatedSprite").play("idle")
			print(target_index)
			
			_handle_damage_dealt(player_turn_order[0], enemies[target_index], target_index, "left", "attack")    # Deal damage to target
			player_turn_order.pop_front()    # Remove player from the turn order
			
			# If there is nobody left, set state to ENEMY and handle that state
			if player_turn_order.size() <= 0:
				current_state = STATES.ENEMY
				handle_states()

# When the enemy does their turn
func _handle_enemy_turn():
	while enemy_turn_order.size() > 0:    # While there are still enemies left to go
		
		if enemy_turn_order[0].current_health > 0:
		
			yield(get_tree().create_timer(1.0), "timeout")    # Add some break between enemies going
		
			# Handle enemy attack animations
			enemy_turn_order[0].get_node("AnimatedSprite").play("attack")
			yield(enemy_turn_order[0].get_node("AnimatedSprite"), "animation_finished")
			enemy_turn_order[0].get_node("AnimatedSprite").play("idle")
		
			# Deal damage to a random target
			var randomTarget = randi() % players.size()
			_handle_damage_dealt(enemy_turn_order[0], players[randomTarget], randomTarget, "right", "attack")
		
		enemy_turn_order.pop_front()    # Remove this person from the turn queue
	
	# When nobody is left, set state to PLAYER
	current_state = STATES.PLAYER
	handle_states()
	
func _update_health(side, index, target):
	if side == "right":
		right_side_hp.get_node("pos" + str(index + 1)).text = str(target.current_health) + "/" + str(target.maximum_health)
	elif side == "left":
		left_side_hp.get_node("pos" + str(index + 1)).text = str(target.current_health) + "/" + str(target.maximum_health)
	
func _handle_enemy_choice_render():
	choose_enemy.clear()
	
	for i in range(0, enemies.size()):
		choose_enemy.add_icon_item(load("res://resources/spell_icons/Fireball.png"), enemies[i].char_name)
		
		if enemies[i].current_health <= 0:
			choose_enemy.set_item_disabled(i, true)
	
# When attack is pressed
func _on_Attack_pressed():
	player_attack_choice = "attack"
	choose_enemy.popup()


func _on_Spells_pressed():
	spell_panel.show()


func _on_SpellExit_pressed():
	spell_panel.hide()


func _on_Spells_item_activated(index):
	spell_panel.hide()
	
	player_attack_choice = "spell"
	
	player_spell_choice = spell_panel.get_node("Spells").get_item_metadata(index)

	choose_enemy.popup()

func _on_ChooseEnemy_id_pressed(id):
	if player_attack_choice == "attack":
		if player_turn_order.size() <= 1:
			interface.hide()
		_handle_player_turn("attack", id)
	elif player_attack_choice == "spell":
		if player_spells.get_node(str(player_spell_choice))._use_magicka(player_turn_order[0]):
			
			if player_turn_order.size() <= 1:
				interface.hide()
	
			enemies[id].add_child(load("res://resources/Animations/Effects/Spell_" + str(player_spell_choice) + ".tscn").instance())
	
			var myChild = enemies[id].get_node("Spell")
			myChild.play("effect")
			yield(myChild, "animation_finished")
			enemies[id].remove_child(myChild)
	
			player_spells.get_node(str(player_spell_choice))._cast_spell(player_turn_order[0], enemies[id])
	
			_handle_damage_dealt(player_turn_order[0], enemies[id], id, "left", "spell")
			
			player_turn_order.pop_front()
			if player_turn_order.size() == 0:
				current_state = STATES.ENEMY
				handle_states()
