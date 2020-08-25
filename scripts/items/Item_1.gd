extends "res://scripts/Item.gd"

class_name Item_1

func _init():
	item_name = "Health Potion"
	description = "Heals the target for 50 health"
	type = ITEM_TYPES.CONSUMABLE
	rarity = GlobalEnums.RARITY.COMMON
	is_stackable = true
	max_stack_size = 99
	
func _use(user, target):
	user.current_health += 30
	
