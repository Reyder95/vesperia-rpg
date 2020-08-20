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

# All of the possible states that the battle can enter
enum STATES {
	PLAYER,
	ENEMY,
	WIN,
	LOSE
}

# Initialize the battle
func _ready():
	
	# DEBUG: Just pushes one playable character, will be adjusted to support all the playable characters
	players.push_back(PlayerData.char1)
	
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
		right_side_hp.get_node("pos" + str(i+1)).text = "Health: " + str(player.current_health) + "/" + str(player.maximum_health)
		
		player.print_stats()    # DEBUG: Just display stats to the console
		
	# Set up the enemies in our enemy array into the scene
	for i in range(0, enemies.size()):
		var enemy = enemies[i]    # Set the current enemy as "enemy"
		
		left_side.get_children()[i].add_child(enemy)    # Set the enemy at the proper position on the left side
		
		# Handle animation. Make sure the enemy animations start at "idle"
		left_side.get_children()[i].get_children()[0].get_node("AnimatedSprite").play("idle")
		
		# Set the left side's HP UI
		left_side_hp.get_node("pos" + str(i+1)).show()
		left_side_hp.get_node("pos" + str(i+1)).text = "Health: " + str(enemy.current_health) + "/" + str(enemy.maximum_health)
		
	for i in range(0, LoadData.spell_data.size()):
		spell_panel.get_node("Spells").add_item( LoadData.spell_data[i].name, load("res://resources/spell_icons/" + LoadData.spell_data[i].name + ".png"))
		spell_panel.get_node("Spells").set_item_tooltip_enabled(i, true)
		spell_panel.get_node("Spells").set_item_tooltip(i, LoadData.spell_data[i].description)
		
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
func _handle_damage_dealt(attacker, target, number, side):
	attacker._attack_entity(target)    # Make the attacker attack the target
	
	if target.current_health == 0:
		print(target.char_name + " is dead")
	
	# Use side to determine which side to modify the HP of
	if side == "right":
		right_side_hp.get_node("pos" + str(number)).text = "Health: " + str(target.current_health) + "/" + str(target.maximum_health)
	elif side == "left":
		print("pos" + str(number))
		left_side_hp.get_node("pos" + str(number)).text = "Health: " + str(target.current_health) + "/" + str(target.maximum_health)

# When the player does their turn
func _handle_player_turn(choice):
	match choice:
		"attack":
			# Handle attacking animations
			player_turn_order[0].get_node("AnimatedSprite").play("attack")
			yield(player_turn_order[0].get_node("AnimatedSprite"), "animation_finished")
			player_turn_order[0].get_node("AnimatedSprite").play("idle")
			
			var randomTarget = randi() % enemies.size()    # DEBUG: Choose a random target. This will be changed
			_handle_damage_dealt(player_turn_order[0], enemies[randomTarget], randomTarget+1, "left")    # Deal damage to target
			player_turn_order.pop_front()    # Remove player from the turn order
			
			# If there is nobody left, set state to ENEMY and handle that state
			if player_turn_order.size() <= 0:
				current_state = STATES.ENEMY
				handle_states()

# When the enemy does their turn
func _handle_enemy_turn():
	while enemy_turn_order.size() > 0:    # While there are still enemies left to go
		
		yield(get_tree().create_timer(1.0), "timeout")    # Add some break between enemies going
		
		# Handle enemy attack animations
		enemy_turn_order[0].get_node("AnimatedSprite").play("attack")
		yield(enemy_turn_order[0].get_node("AnimatedSprite"), "animation_finished")
		enemy_turn_order[0].get_node("AnimatedSprite").play("idle")
		
		# Deal damage to a random target
		var randomTarget = randi() % players.size()
		_handle_damage_dealt(enemy_turn_order[0], players[randomTarget], randomTarget+1, "right")
		
		enemy_turn_order.pop_front()    # Remove this person from the turn queue
	
	# When nobody is left, set state to PLAYER
	current_state = STATES.PLAYER
	handle_states()
	
# When attack is pressed
func _on_Attack_pressed():
	_handle_player_turn("attack")


func _on_Spells_pressed():
	spell_panel.show()


func _on_SpellExit_pressed():
	spell_panel.hide()
