extends "res://scripts/Entity.gd"

export var experience : int    # Number of experience the player has. This is used to determine their level

# An object for a character's gear. They will preload different gear scenes
var gear = {
	"head": null,
	"body": null,
	"legs": null,
	"feet": null,
	"weapons": {
		"left": null,
		"right": null
	}
}
