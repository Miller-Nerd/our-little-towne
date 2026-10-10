# Our Little Towne - Project Documentation

## Overview
This is a mobile game project built with Godot 4.72, featuring a main menu with character selection functionality.

## Design Decisions

### Mobile First Approach
- **Orientation**: Portrait mode (vertical orientation) for mobile compatibility
- **Navigation**: No quit button as mobile apps are typically closed by the OS
- **UI Scaling**: Control nodes with proper anchor settings for responsive layout

### Scene Structure
- `main_menu.tscn`: Main menu with Play, Settings buttons
- `character_select.tscn`: Character selection screen with 5 character slots
- `main_game.tscn`: Basic game scene (placeholder)
- `settings.tscn`: Settings panel with Back button

### Technical Implementation

#### Button Connections
- All buttons properly connected via Godot's signal system
- Signal connections use minimal node access patterns for compatibility
- Debug output added to trace execution flow

#### Script Attachments
- Both `main_menu.gd` and `character_select.gd` scripts attached to their respective scenes
- Proper resource references in scene files

#### Compatibility Considerations
- Avoided DisplayServer API calls due to Godot 4.72 compatibility issues
- Used minimal node access patterns throughout
- Ensured proper scene loading with error handling

### Character Selection Screen Implementation

The character selection screen now has the following functionality:
- 5 character slots displayed in a vertical layout
- Empty character slots show "Character X" where X is the slot number
- Class and level labels are hidden when no character data exists
- Create Character labels only appear when slots are empty
- Data formatting: "Class: Mage", "Level: 1" for filled slots

#### Node Structure
- CharacterSlotX nodes contain:
  - CharacterSlotX#CharacterInfoX container with:
    - CharacterNameX label
    - CharacterClassX label  
    - CharacterLevelX label
  - CharacterSlotX#CreateCharacterX label

#### Data Handling
- Characters array stores character data with name, class, and level fields
- Empty slots have empty strings for all fields
- Proper visibility control for labels based on character data presence

### File Structure
```
project/
├── main_menu.tscn          # Main menu UI
├── main_menu.gd           # Main menu logic
├── character_select.tscn  # Character selection UI
├── character_select.gd    # Character selection logic
├── main_game.tscn         # Game scene (placeholder)
├── settings.tscn          # Settings panel UI
├── settings.gd            # Settings panel logic
├── project.godot          # Project configuration
├── base.tscn              # Base scene template
├── icon.svg               # Game icon
└── README.md              # Documentation
```

### Testing Instructions
1. Open project in Godot 4.72 editor
2. Run the project to verify:
   - Main menu loads correctly
   - Play button connects and changes scenes to character selection
   - Settings button toggles visibility of settings panel
   - Debug output appears in console when buttons are pressed
   - Character selection screen shows proper formatting for empty and filled slots

### Known Issues
- DisplayServer API calls were commented out due to compatibility issues with Godot 4.72
- Scene loading relies on proper file paths and resource references
- Mobile orientation is set to portrait mode as per requirements

### Future Improvements
- Add actual character creation functionality
- Implement save/load system for characters
- Add more comprehensive settings options
- Include sound effects and music
- Add animations and visual polish