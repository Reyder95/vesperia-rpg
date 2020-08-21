extends "res://scripts/Spell.gd"

func _ready():
	spellname = "Ice Beam"
	spellpower = 80
	spellcost = 10
	element = Elements.ICE
	
func _cast_spell(user, target):
	var damage = user.intelligence + spellpower
	target._take_damage(damage)
