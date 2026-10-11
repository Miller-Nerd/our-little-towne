extends Control

# Character data structure - empty slots will have empty strings
var characters = [
	{ "name": "", "class": "", "level": "" },  # Empty slot 1
	{ "name": "", "class": "", "level": "" },  # Empty slot 2
	{ "name": "", "class": "", "level": "" },  # Empty slot 3
	{ "name": "", "class": "", "level": "" },  # Empty slot 4
	{ "name": "", "class": "", "level": "" }   # Empty slot 5
]

func _ready():
	print("Character select scene loaded")
	
	# Check if a new character was just created and save it to the slot
	var tree = get_tree()
	if tree.has_meta("created_character_data"):
		var created_data = tree.get_meta("created_character_data")
		var slot_idx = created_data["slot_number"] - 1
		characters[slot_idx] = {
			"name": created_data["name"],
			"class": created_data["class"],
			"level": "Level 1"
		}
		print("Saved new character to slot " + str(created_data["slot_number"]))
		tree.set_meta("created_character_data", null)
	
	# Load saved characters from local storage
	load_saved_characters()
	
	# Connect back button
	var back_button = $BackButton
	if back_button:
		print("Found BackButton, connecting...")
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
		print("Back button connected successfully")
	else:
		print("ERROR: Could not find BackButton node")
	
	# Update character slots with proper data handling
	update_character_display()

func load_saved_characters():
	# Load all saved characters from local storage
	var save_dir = "user://save_data"
	
	# Create the directory if it doesn't exist (though it should already exist from saving)
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)
	
	# Check if the directory exists and is accessible
	var dir = DirAccess.open(save_dir)
	if dir == null:
		print("Failed to open save directory: " + save_dir)
		return
	
	# Iterate through all files in the save directory
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("character_slot_") and file_name.ends_with(".json"):
			var number_str = file_name.substr(13, file_name.length() - 17)  # Extract the number between "character_slot_" and ".json"
			var slot_number = int(number_str)
			
			if slot_number >= 1 and slot_number <= 5:
				# Load this character data
				var file_path = save_dir + "/" + file_name
				load_character_from_file(slot_number, file_path)
		
		file_name = dir.get_next()

func load_character_from_file(slot_number, file_path):
	# Load the character data from a JSON file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Failed to open character file: " + file_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Use the static method parse_string to parse JSON (this returns parsed data or null on failure)
	var json_data = JSON.parse_string(content)
	
	# Check if parsing was successful
	if json_data != null:
		print("Loaded character data for slot " + str(slot_number) + ": ", json_data)
		# Update the characters array with loaded data
		var idx = slot_number - 1
		if idx >= 0 and idx < characters.size():
			characters[idx] = {
				"name": json_data.name,
				"class": json_data.class,
				"level": "Level 1"
			}
	else:
		print("Failed to parse JSON from file: " + file_path)

func update_character_display():
	for i in range(5):
		var slot_path = "CharacterList/CharacterSlot" + str(i+1)
		var slot = get_node_or_null(slot_path)
		if not slot:
			continue
		
		var character = characters[i]
		
		# Update labels using proper node paths
		var name_label = slot.get_node_or_null("CharacterSlot" + str(i+1) + "#CharacterInfo" + str(i+1) + "/CharacterInfo" + str(i+1) + "#CharacterName" + str(i+1))
		var class_label = slot.get_node_or_null("CharacterSlot" + str(i+1) + "#CharacterInfo" + str(i+1) + "/CharacterInfo" + str(i+1) + "#CharacterClass" + str(i+1))
		var level_label = slot.get_node_or_null("CharacterSlot" + str(i+1) + "#CharacterInfo" + str(i+1) + "/CharacterInfo" + str(i+1) + "#CharacterLevel" + str(i+1))
		
		# Update name label
		if name_label:
			name_label.text = character["name"] if character["name"] != "" else "Character " + str(i+1)
		
		# Show/hide class and level labels based on whether there's character data
		if character["name"] == "" and character["class"] == "" and character["level"] == "":
			# No character data - hide class/level labels and show create character button
			if class_label:
				class_label.visible = false
			if level_label:
				level_label.visible = false
			
			# Show create button
			var create_button = slot.get_node_or_null("CharacterSlot" + str(i+1) + "#CreateCharacter" + str(i+1))
			if create_button:
				create_button.visible = true
				
				# Connect the button to the creation function if it isn't already connected
				if not create_button.is_connected("pressed", Callable(self, "_on_create_character_pressed").bind(i+1)):
					create_button.connect("pressed", Callable(self, "_on_create_character_pressed").bind(i+1))
					print("Connected create button for slot " + str(i+1))
		else:
			# We have character data - show class/level labels with proper formatting
			if class_label:
				class_label.visible = true
				class_label.text = "Class: " + character["class"]
			if level_label:
				level_label.visible = true
				level_label.text = "Level: " + character["level"]
			
			# Hide create button when there's character data
			var create_button = slot.get_node_or_null("CharacterSlot" + str(i+1) + "#CreateCharacter" + str(i+1))
			if create_button:
				create_button.visible = false
			
			# Show and connect Play button for slots with character data
			var play_button = slot.get_node_or_null("PlayButton")
			if play_button:
				play_button.visible = true
				if not play_button.is_connected("pressed", Callable(self, "_on_select_character_pressed").bind(i+1)):
					play_button.connect("pressed", Callable(self, "_on_select_character_pressed").bind(i+1))

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
	
	# Get character data for this slot
	var char_data = characters[slot_number - 1]
	if char_data.name == "" and char_data.class == "" and char_data.level == "":
		print("No character data in slot " + str(slot_number) + ", redirecting to creation")
		_on_create_character_pressed(slot_number)
	else:
		print("Got character data: ", char_data)
		# Pass character data to next scene
		get_tree().set_meta("character_data", char_data)
		
		# Check if we're in host mode - route to world selection instead of lobby host setup
		if get_tree().has_meta("host_mode") and get_tree().get_meta("host_mode"):
			print("Host mode detected, navigating to world selection")
			get_tree().change_scene_to_file("res://world_selection.tscn")
		else:
			# Navigate to server selection scene (IP entry / server browser)
			get_tree().change_scene_to_file("res://server_select.tscn")
