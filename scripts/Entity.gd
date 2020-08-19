extends Node2D

# A base class that handles all of the Entities in the game

class_name CharacterEntity

export var char_name : String    # Name of the Entity
export var level : int    # Level that the entity is. Playable will have experience	

export var maximum_health : int    # Maximum health of this entity
export var current_health : int = maximum_health    # Current health of the entity, defaults to equal the maximum health

# Stats (will be considered base stats for playable characters, as they will also have gear as well)
export var attack : int    # The amount of base damage done
export var armor : int    # Reduces damage taken
export var strength : int    # Increases raw strength damage dealt (harder hitting weapons)
export var dexterity : int    # Increases nimble / agile damage dealt (lighter but faster hitting weapons)
export var intelligence : int     # Increases magic damage dealt and maximum amount of magicka stored

# Print the stats of the current object
func print_stats():
	print("Name: " + char_name)
	print("Level: " + str(level))
	print("Max Health: " + str(maximum_health))
	print("Current Health: " + str(current_health))
	print("Attack: " + str(attack))
	print("Armor: " + str(armor))
	print("Strength: " + str(strength))
	print("Dexterity: " + str(dexterity))
	print("Intelligence: " + str(intelligence))

# Do some damage to an entity
func _attack_entity(entity):
	entity._take_damage(attack)
	
# Receive damage and handle it
func _take_damage(damage):
	current_health -= damage    # Reduce current amount of health
	
	# If health is below 0, set it to 0
	if current_health < 0:
		current_health = 0
		

