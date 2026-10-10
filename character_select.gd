extends Control

# Character data structure - empty slots will have empty strings
var characters = [
	{ "name": "", "class": "", "level": "" },  # Empty slot 1
	{ "name": "Character 2", "class": "Mage", "level": "Level 1" },  # Filled slot 2
	{ "name": "", "class": "", "level": "" },  # Empty slot 3
	{ "name": "Character 4", "class": "Paladin", "level": "Level 1" },  # Filled slot 4
	{ "name": "", "class": "", "level": "" }   # Empty slot 5
]

func _ready():
	print("Character select scene loaded")
	
	# Connect back button
	var back_button = $BackButton
	if back_button:
		print("Found BackButton, connecting...")
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
		print("Back button connected successfully")
	else:
		print("ERROR: Could not find BackButton node")
	
	# Update character slots with proper data handling
	update_character_slots()

func update_character_slots():
	print("Updating character slots...")
	for i in range(1, 6):
		print("Processing slot " + str(i))
		
		# Get the slot node properly using get_node
		var slot = get_node("CharacterList/CharacterSlot" + str(i))
		if not slot:
			print("Could not find CharacterSlot" + str(i))
			continue
			
		# Get all the labels for this character slot - direct approach
		var name_label = null
		var class_label = null
		var level_label = null
		var create_label = null
		
		# Direct access to child nodes by their actual names in the scene
		name_label = slot.get_node_or_null("CharacterSlot" + str(i) + "#CharacterInfo" + str(i) + "/CharacterName" + str(i))
		class_label = slot.get_node_or_null("CharacterSlot" + str(i) + "#CharacterInfo" + str(i) + "/CharacterClass" + str(i))
		level_label = slot.get_node_or_null("CharacterSlot" + str(i) + "#CharacterInfo" + str(i) + "/CharacterLevel" + str(i))
		create_label = slot.get_node_or_null("CharacterSlot" + str(i) + "#CreateCharacter" + str(i))
		
		if not name_label or not class_label or not level_label:
			print("Could not find labels for CharacterSlot" + str(i) + " - skipping")
			continue
		
		# Get character data
		var char_data = characters[i-1]
		print("Slot " + str(i) + " data: name='" + char_data.name + "', class='" + char_data.class + "', level='" + char_data.level + "'")
		
		# Set name - if no character data, show "Character X"
		if char_data.name == "":
			name_label.text = "Character " + str(i)
			name_label.visible = true
		else:
			name_label.text = char_data.name
		
		# Show/hide class and level labels based on whether there's character data
		if char_data.name == "" and char_data.class == "" and char_data.level == "":
			print("Slot " + str(i) + ": No character data - hiding class/level labels")
			# No character data - hide class/level labels and show create character
			class_label.visible = false
			level_label.visible = false
		else:
			print("Slot " + str(i) + ": Has character data - showing class/level labels")
			# We have character data - show class/level labels with proper formatting
			class_label.visible = true
			level_label.visible = true
			class_label.text = "Class: " + char_data.class
			level_label.text = "Level: " + char_data.level
		
		# Show create character label when there's no data
		if char_data.name == "" and char_data.class == "" and char_data.level == "":
			create_label.visible = true
		else:
			create_label.visible = false

func _on_back_button_pressed():
	print("Back button pressed - changing scene")
	get_tree().change_scene_to_file("res://main_menu.tscn")