# Our Little Towne

A mobile game built with Godot 4.72.

## Features

- Mobile-optimized vertical orientation
- Main menu with Play, Settings options
- Character selection screen with 5 character slots
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
- `main_game.tscn` - Basic game scene
- `settings.tscn` - Settings panel scene
- `settings.gd` - Settings panel script

## Controls

- Play: Start the game (takes you to character selection)
- Settings: Open settings menu
- Back: Return to main menu from character selection or settings

## Mobile Optimization

The game is designed for vertical mobile orientation with responsive UI elements.