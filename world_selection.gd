extends Control

# World data structure - empty slots will have empty strings
var worlds = [
	{ "name": "", "last_played": "" },  # Empty slot 1
	{ "name": "", "last_played": "" },  # Empty slot 2
	{ "name": "", "last_played": "" }   # Empty slot 3
]

func _ready():
	print("World selection scene loaded")
	
	# Load saved worlds from local storage
	load_saved_worlds()
	
	# Connect back button
	var back_button = $BackButton
	if back_button:
		print("Found BackButton, connecting...")
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
		print("Back button connected successfully")
	
	# Connect world slot buttons
	connect_world_buttons()
	
	# Update world slots with proper data handling
	update_world_display()

func load_saved_worlds():
	# Load all saved worlds from local storage
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
		if file_name.begins_with("world_") and file_name.ends_with(".json"):
			# Extract world name from filename (remove "world_" prefix and ".json" suffix)
			var world_name = file_name.substr(6, file_name.length() - 10)  # Remove "world_" prefix and ".json" suffix
			world_name = world_name.replace("_", " ")  # Convert underscores back to spaces
			
			# Load this world data
			var file_path = save_dir + "/" + file_name
			load_world_from_file(world_name, file_path)
	
		file_name = dir.get_next()

func load_world_from_file(world_name, file_path):
	# Load the world data from a JSON file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("Failed to open world file: " + file_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Use the static method parse_string to parse JSON (this returns parsed data or null on failure)
	var json_data = JSON.parse_string(content)
	
	# Check if parsing was successful
	if json_data != null:
		print("Loaded world data: ", json_data)
		
		# Find a free slot to put this world in
		for i in range(3):
			if worlds[i]["name"] == "":
				worlds[i] = {
					"name": json_data.name,
					"last_played": json_data.last_played
				}
				print("Stored world '" + world_name + "' in slot " + str(i+1))
				break
	else:
		print("Failed to parse JSON from file: " + file_path)

func update_world_display():
	for i in range(3):
		var slot_path = "WorldList/WorldSlot" + str(i+1)
		var slot = get_node_or_null(slot_path)
		if not slot:
			continue
		
		var world = worlds[i]
		
		# Update labels using proper node paths
		var name_label = slot.get_node_or_null("WorldSlot" + str(i+1) + "#WorldInfo" + str(i+1) + "/WorldInfo" + str(i+1) + "#WorldName" + str(i+1))
		var last_played_label = slot.get_node_or_null("WorldSlot" + str(i+1) + "#WorldInfo" + str(i+1) + "/WorldInfo" + str(i+1) + "#WorldLastPlayed" + str(i+1))
		
		# Update name label
		if name_label:
			name_label.text = world["name"] if world["name"] != "" else "World " + str(i+1)
		
		# Update last played label
		if last_played_label:
			last_played_label.text = "Last played: " + (world["last_played"] if world["last_played"] != "" else "Never")
		
		# Show/hide create and join buttons based on whether there's world data
		var create_button = slot.get_node_or_null("WorldSlot" + str(i+1) + "#CreateWorld" + str(i+1))
		var join_button = slot.get_node_or_null("JoinButton")
		
		if world["name"] == "" and world["last_played"] == "":
			# No world data - show create button and hide join button
			if create_button:
				create_button.visible = true
			if join_button:
				join_button.visible = false
		else:
			# We have world data - show join button and hide create button
			if create_button:
				create_button.visible = false
			if join_button:
				join_button.visible = true

func connect_world_buttons():
	# Connect create world buttons
	for i in range(1, 4):  # Three worlds
		var create_button = get_node_or_null("WorldList/WorldSlot" + str(i) + "/WorldSlot" + str(i) + "#CreateWorld" + str(i))
		if create_button:
			print("Connecting world " + str(i) + " create button")
			create_button.connect("pressed", Callable(self, "_on_create_world_pressed").bind(i))
	
	# Connect join buttons (will be shown for existing worlds)
	for i in range(1, 4):
		var join_button = get_node_or_null("WorldList/WorldSlot" + str(i) + "/JoinButton")
		if join_button:
			print("Connecting world " + str(i) + " join button")
			join_button.connect("pressed", Callable(self, "_on_join_world_pressed").bind(i))

func _on_back_button_pressed():
	print("Back button pressed - changing scene")
	get_tree().change_scene_to_file("res://character_select.tscn")

func _on_create_world_pressed(world_number):
	print("Create world " + str(world_number) + " pressed")
	# Store the world number for use in create world scene
	get_tree().set_meta("world_creation_slot", world_number)
	# Navigate to create world scene (which doesn't exist yet, but we'll set up the navigation)
	get_tree().change_scene_to_file("res://create_world.tscn")

func _on_join_world_pressed(world_number):
	print("Join world " + str(world_number) + " pressed")
	
	# Get character data from meta
	var char_data = get_tree().get_meta("character_data")
	if char_data == null:
		print("No character data found!")
		return
	
	# Set up the world data for lobby host setup
	get_tree().set_meta("character_data", char_data)
	get_tree().set_meta("world_number", world_number)
	
	# Navigate to lobby host setup (this will be our new flow)
	get_tree().change_scene_to_file("res://lobby_host_setup.tscn")
