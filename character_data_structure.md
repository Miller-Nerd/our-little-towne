# Character Data Structure Draft

## Individual Character Slot Format
Each character slot should contain:
- `name` (string): The character's name
- `class` (string): The character's class 
- `level` (integer): The character's level
- `experience` (integer): Current experience points
- `appearance` (dictionary): The appearance choices made in Character Creation
- `stats` (dictionary): Character stats like strength, dexterity, etc.
- `inventory` (array): List of items the character has

## Example Structure
```json
{
  "name": "Aragorn",
  "class": "Ranger",
  "level": 5,
  "experience": 1250,
  "appearance": {
    "gender": 1,
    "hair": 3,
    "hair_color": 7,
    "skin": 3,
    "eyes": 2,
    "eye_color": 4,
  },
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
  ]
}
```

## Data Storage Options
1. **In-memory array** (current approach) - simple for prototype
2. **Save file system** - persistent storage
3. **Database** - more complex but scalable
