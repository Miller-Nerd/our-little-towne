# Character Data Structure Draft

## Individual Character Slot Format
Each character slot should contain:
- `name` (string): The character's name
- `class` (string): The character's class 
- `level` (integer): The character's level
- `experience` (integer): Current experience points
- `stats` (dictionary): Character stats like strength, dexterity, etc.
- `inventory` (array): List of items the character has
- `abilities` (array): List of abilities/spells the character knows

## Example Structure
```json
{
  "name": "Aragorn",
  "class": "Ranger",
  "level": 5,
  "experience": 1250,
  "stats": {
    "strength": 12,
    "dexterity": 18,
    "intelligence": 10,
    "constitution": 14
  },
  "inventory": [
    "Longbow",
    "Leather Armor",
    "Health Potion"
  ],
  "abilities": [
    "Marksmanship",
    "Stealth",
    "Track"
  ]
}
```

## Data Storage Options
1. **In-memory array** (current approach) - simple for prototype
2. **Save file system** - persistent storage
3. **Database** - more complex but scalable