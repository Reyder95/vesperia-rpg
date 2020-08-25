extends Node

class_name Item

enum ITEM_TYPES {
	CONSUMABLE,
	MATERIAL,
	GEAR
}

var item_name
var description
var type
var rarity
var choice
var is_stackable
var max_stack_size

func _init():
	pass

func _use(user, target):
	pass
