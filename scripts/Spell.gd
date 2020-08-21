extends Node2D

class_name Spell

enum Elements {
	FIRE,
	ICE,
	WATER,
	AIR,
	ARCANE,
	ELECTRIC
}

var spellname
var spellpower 
var spellcost 
var element    # The element of the spell

func _init():
	pass

func _use_magicka(character):
	if character.magicka < spellcost:
		return false
	else:
		character.magicka -= spellcost
		return true

func _cast_spell(user, target):
	pass
