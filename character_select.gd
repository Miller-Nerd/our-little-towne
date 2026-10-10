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
		var slot = get_node_or_null("CharacterList/CharacterSlot" + str(i))
		if not slot:
			print("Could not find CharacterSlot" + str(i))
			continue
			
		# Get all the labels for this character slot - direct approach
		var name_label = null
		var class_label = null
		var level_label = null
		var create_button = null
		
		# Direct access to child nodes by their actual names in the scene
		name_label = slot.get_node_or_null("CharacterSlot" + str(i) + "#CharacterInfo" + str(i) + "/CharacterInfo" + str(i) + "#CharacterName" + str(i))
		class_label = slot.get_node_or_null("CharacterSlot" + str(i) + "#CharacterInfo" + str(i) + "/CharacterInfo" + str(i) + "#CharacterClass" + str(i))
		level_label = slot.get_node_or_null("CharacterSlot" + str(i) + "#CharacterInfo" + str(i) + "/CharacterInfo" + str(i) + "#CharacterLevel" + str(i))
		create_button = slot.get_node_or_null("CharacterSlot" + str(i) + "#CreateCharacter" + str(i))
		
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
			# No character data - hide class/level labels and show create character button
			class_label.visible = false
			level_label.visible = false
			
			# Make sure the create button is visible (it's a button now, not a label)
			if create_button:
				create_button.visible = true
				# Connect the button to the creation function if it isn't already connected
				if not create_button.is_connected("pressed", Callable(self, "_on_create_character_pressed").bind(i)):
					create_button.connect("pressed", Callable(self, "_on_create_character_pressed").bind(i))
					print("Connected create button for slot " + str(i))
		else:
			print("Slot " + str(i) + ": Has character data - showing class/level labels")
			# We have character data - show class/level labels with proper formatting
			class_label.visible = true
			level_label.visible = true
			class_label.text = "Class: " + char_data.class
			level_label.text = "Level: " + char_data.level
			
			# Hide create button when there's character data
			if create_button:
				create_button.visible = false

func _on_back_button_pressed():
	print("Back button pressed - changing scene")
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_create_character_pressed(slot_number):
	print("Create character button pressed for slot " + str(slot_number))
	# Navigate to character creation scene for this slot
	# Pass the slot number as a parameter
	var params = {
		"slot_number": slot_number
	}
	get_tree().set_meta("character_creation_params", params)
	var result = get_tree().change_scene_to_file("res://character_creation.tscn")
	if result != OK:
		print("Failed to change to character creation scene: ", result)
	else:
		print("Navigated to character creation scene")

func _on_select_character_pressed(slot_number):
	print("Select character button pressed for slot " + str(slot_number))
	# In a real implementation, we would save the selected character data
	# For now, just go to connection attempt scene
	print("Character from slot " + str(slot_number) + " selected")
	
	# Get character data for this slot
	var char_data = characters[slot_number - 1]
	if char_data.name == "" and char_data.class == "" and char_data.level == "":
		print("No character data in slot " + str(slot_number) + ", redirecting to creation")
		_on_create_character_pressed(slot_number)
	else:
		print("Got character data: ", char_data)
		# Pass character data to connection attempt scene
		get_tree().set_meta("character_data", char_data)
		get_tree().change_scene_to_file("res://connection_attempt.tscn")
