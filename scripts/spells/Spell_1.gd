extends "res://scripts/Spell.gd"

class_name Spell_1

func _init():
	spellname = "Fireball"
	spellpower = 120
	spellcost = 200
	element = Elements.FIRE
	
func _cast_spell(user, target):
	var damage = user.intelligence + spellpower
	return target._take_damage(damage)
