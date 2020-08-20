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

export var spellname : String
export var spellpower : int
export var spellcost : int
var element    # The element of the spell

func _cast_spell(user, target):
	pass
