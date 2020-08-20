extends "res://scripts/Spell.gd"


func _ready():
	spellname = "Fireball"
	spellpower = 120
	spellcost = 25
	element = Elements.FIRE
	
func _cast_spell(user, target):
	var damage = user.intelligence + spellpower
	target._take_damage(damage)
