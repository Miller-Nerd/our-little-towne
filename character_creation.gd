extends Control

# Slot number that this character creation is for
var slot_number = 1

# Character appearance data
var character_appearance = {
	"gender": 1,
	"hair": 1,
	"hair_color": 1,
	"skin": 1,
	"eyes": 1,
	"eye_color": 1
}

func _ready():
	print("Character creation scene loaded")
	
	# Get the slot number from the scene parameters if available
	# This will be passed from character_select when creating a new character
	var params = get_tree().get_meta("character_creation_params", {})
	if params.has("slot_number"):
		slot_number = params.slot_number
		print("Creating character for slot: " + str(slot_number))
	
	# Connect back button
	var back_button = $BackButton
	if back_button:
		print("Found BackButton, connecting...")
		back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
		print("Back button connected successfully")
	
	# Connect create button
	var create_button = $CreateButton
	if create_button:
		print("Found CreateButton, connecting...")
		create_button.connect("pressed", Callable(self, "_on_create_button_pressed"))
		print("Create button connected successfully")
	
	# Connect all the navigation buttons
	connect_navigation_buttons()
	
	# Initialize the appearance values
	update_appearance_display()

func connect_navigation_buttons():
	# Gender navigation
	var gender_left = $GenderContainer/GenderLeftButton
	var gender_right = $GenderContainer/GenderRightButton
	if gender_left:
		gender_left.connect("pressed", Callable(self, "_on_gender_left_pressed"))
	if gender_right:
		gender_right.connect("pressed", Callable(self, "_on_gender_right_pressed"))
	
	# Hair style navigation
	var hair_style_left = $HairStyleContainer/HairStyleLeftButton
	var hair_style_right = $HairStyleContainer/HairStyleRightButton
	if hair_style_left:
		hair_style_left.connect("pressed", Callable(self, "_on_hair_style_left_pressed"))
	if hair_style_right:
		hair_style_right.connect("pressed", Callable(self, "_on_hair_style_right_pressed"))
	
	# Hair color navigation
	var hair_color_left = $HairColorContainer/HairColorLeftButton
	var hair_color_right = $HairColorContainer/HairColorRightButton
	if hair_color_left:
		hair_color_left.connect("pressed", Callable(self, "_on_hair_color_left_pressed"))
	if hair_color_right:
		hair_color_right.connect("pressed", Callable(self, "_on_hair_color_right_pressed"))
	
	# Eye shape navigation
	var eye_shape_left = $EyeShapeContainer/EyeShapeLeftButton
	var eye_shape_right = $EyeShapeContainer/EyeShapeRightButton
	if eye_shape_left:
		eye_shape_left.connect("pressed", Callable(self, "_on_eye_shape_left_pressed"))
	if eye_shape_right:
		eye_shape_right.connect("pressed", Callable(self, "_on_eye_shape_right_pressed"))
	
	# Eye color navigation
	var eye_color_left = $EyeColorContainer/EyeColorLeftButton
	var eye_color_right = $EyeColorContainer/EyeColorRightButton
	if eye_color_left:
		eye_color_left.connect("pressed", Callable(self, "_on_eye_color_left_pressed"))
	if eye_color_right:
		eye_color_right.connect("pressed", Callable(self, "_on_eye_color_right_pressed"))
	
	# Skin color navigation
	var skin_color_left = $SkinColorContainer/SkinColorLeftButton
	var skin_color_right = $SkinColorContainer/SkinColorRightButton
	if skin_color_left:
		skin_color_left.connect("pressed", Callable(self, "_on_skin_color_left_pressed"))
	if skin_color_right:
		skin_color_right.connect("pressed", Callable(self, "_on_skin_color_right_pressed"))

func update_appearance_display():
	# Update all value labels with current appearance values
	$GenderContainer/GenderValueLabel.text = str(character_appearance.gender)
	$HairStyleContainer/HairStyleValueLabel.text = str(character_appearance.hair)
	$HairColorContainer/HairColorValueLabel.text = str(character_appearance.hair_color)
	$EyeShapeContainer/EyeShapeValueLabel.text = str(character_appearance.eyes)
	$EyeColorContainer/EyeColorValueLabel.text = str(character_appearance.eye_color)
	$SkinColorContainer/SkinColorValueLabel.text = str(character_appearance.skin)

func _on_back_button_pressed():
	print("Back button pressed - changing scene")
	get_tree().change_scene_to_file("res://character_select.tscn")

func _on_create_button_pressed():
	print("Create character button pressed")
	
	# Get the character name
	var name_input = $CharacterNameContainer/NameInput
	var character_name = ""
	if name_input:
		character_name = name_input.text
	
	# Get the character class
	var class_dropdown = $CharacterClassContainer/ClassDropdown
	var character_class = ""
	if class_dropdown:
		character_class = class_dropdown.get_item_text(class_dropdown.selected)
	
	print("Creating character: Name='" + character_name + "', Class='" + character_class + "', Slot=" + str(slot_number))
	
	# In a real implementation, we would save this data to the player's profile
	# For now, just go back to character selection
	var params = {
		"slot_number": slot_number,
		"name": character_name,
		"class": character_class,
		"appearance": character_appearance
	}
	
	# Store the character data in the scene meta so it can be retrieved by character_select
	get_tree().set_meta("created_character_data", params)
	
	get_tree().change_scene_to_file("res://character_select.tscn")

func _on_gender_left_pressed():
	character_appearance.gender -= 1
	if character_appearance.gender < 1:
		character_appearance.gender = 2  # Max gender value is 2 (male/female)
	update_appearance_display()

func _on_gender_right_pressed():
	character_appearance.gender += 1
	if character_appearance.gender > 2:
		character_appearance.gender = 1  # Min gender value is 1 (male/female)
	update_appearance_display()

func _on_hair_style_left_pressed():
	character_appearance.hair -= 1
	if character_appearance.hair < 1:
		character_appearance.hair = 5  # Max hair style value is 5
	update_appearance_display()

func _on_hair_style_right_pressed():
	character_appearance.hair += 1
	if character_appearance.hair > 5:
		character_appearance.hair = 1  # Min hair style value is 1
	update_appearance_display()

func _on_hair_color_left_pressed():
	character_appearance.hair_color -= 1
	if character_appearance.hair_color < 1:
		character_appearance.hair_color = 10  # Max hair color value is 10
	update_appearance_display()

func _on_hair_color_right_pressed():
	character_appearance.hair_color += 1
	if character_appearance.hair_color > 10:
		character_appearance.hair_color = 1  # Min hair color value is 1
	update_appearance_display()

func _on_eye_shape_left_pressed():
	character_appearance.eyes -= 1
	if character_appearance.eyes < 1:
		character_appearance.eyes = 4  # Max eye shape value is 4
	update_appearance_display()

func _on_eye_shape_right_pressed():
	character_appearance.eyes += 1
	if character_appearance.eyes > 4:
		character_appearance.eyes = 1  # Min eye shape value is 1
	update_appearance_display()

func _on_eye_color_left_pressed():
	character_appearance.eye_color -= 1
	if character_appearance.eye_color < 1:
		character_appearance.eye_color = 8  # Max eye color value is 8
	update_appearance_display()

func _on_eye_color_right_pressed():
	character_appearance.eye_color += 1
	if character_appearance.eye_color > 8:
		character_appearance.eye_color = 1  # Min eye color value is 1
	update_appearance_display()

func _on_skin_color_left_pressed():
	character_appearance.skin -= 1
	if character_appearance.skin < 1:
		character_appearance.skin = 5  # Max skin color value is 5
	update_appearance_display()

func _on_skin_color_right_pressed():
	character_appearance.skin += 1
	if character_appearance.skin > 5:
		character_appearance.skin = 1  # Min skin color value is 1
	update_appearance_display()