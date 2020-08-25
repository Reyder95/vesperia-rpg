extends Node

class_name Inventory

var items = Array()
var capacity

func _init():
	capacity = 30
	
func _add_item(item):
	
	if items.size() < capacity:
		var item_found = false
	
		var inventory_item = preload("res://InventoryItem.tscn").instance()
		inventory_item.item = item
		inventory_item.quantity = 1
		
		for my_inventory_item in items:
			if my_inventory_item.item.item_name == item.item_name:
				item_found = true
				if item.is_stackable:
					if my_inventory_item.quantity < item.max_stack_size:
						my_inventory_item._increase_quantity()
						break
					else:
						items.push_back(inventory_item)
						break
				else:
					items.push_back(inventory_item)
					break
	
		if not item_found:
			items.push_back(inventory_item)
				
		
func _get_items():
	return items
