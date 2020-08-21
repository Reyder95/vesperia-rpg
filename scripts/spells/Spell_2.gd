extends "res://scripts/Spell.gd"

func _init():
	spellname = "Ice Beam"
	spellpower = 80
	spellcost = 10
	element = Elements.ICE
	
func _cast_spell(user, target):
	var damage = user.intelligence + spellpower
	return target._take_damage(damage)
