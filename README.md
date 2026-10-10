# Our Little Towne

A PC-first multiplayer game built with Godot 4.72.

## Features

- PC-optimized horizontal orientation
- Main menu with Play, Settings options
- Character selection screen with 5 character slots (for lobby system)
- Player lobby system supporting up to 8 players
- Basic game scene structure
- Settings panel

## Getting Started

1. Open this project in Godot 4.72
2. Set `main_menu.tscn` as the main scene in Project Settings
3. Run the project

## Project Structure

- `main_menu.tscn` - Main menu scene with UI elements
- `main_menu.gd` - Script for main menu functionality
- `character_select.tscn` - Character selection screen with 5 slots
- `character_select.gd` - Script for character selection functionality
- `lobby.tscn` - Player lobby system scene with 8 player slots
- `lobby.gd` - Script for lobby functionality
- `character_creation.tscn` - Character creation scene
- `character_creation.gd` - Script for character creation functionality
- `main_game.tscn` - Basic game scene
- `settings.tscn` - Settings panel scene
- `settings.gd` - Settings panel script

## Controls

- Play: Start the game (takes you to lobby system)
- Settings: Open settings menu
- Back: Return to main menu from character selection or settings

## PC Optimization

The game is designed for PC with horizontal orientation and multiplayer lobby support.