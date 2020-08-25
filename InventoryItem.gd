extends Node2D

class_name InventoryItem

var item
var quantity

func _increase_quantity():
	quantity += 1
	
func _use_item(user, target):
	item._use(user, target)
