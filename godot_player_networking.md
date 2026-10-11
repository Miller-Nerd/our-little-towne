# Godot 4 - Implementing Player Visibility in Multiplayer Games

## Overview

In Godot 4, implementing players seeing each other move requires using the high-level multiplayer networking system. This approach leverages Remote Procedure Calls (RPCs) to synchronize player positions across all connected peers in the same scene.

## Core Concepts

### Multiplayer Architecture
Godot's multiplayer system uses a mid-level abstraction through the `MultiplayerPeer` object, which can be implemented using:
- ENet (`ENetMultiplayerPeer`) - Most common for UDP-based networking
- WebRTC (`WebRTCMultiplayerPeer`) - For peer-to-peer connections
- WebSocket (`WebSocketMultiplayerPeer`) - For web-based connections

### Network Topology
- **Server**: Central authority that manages the game state
- **Clients**: Player instances that connect to the server
- Each peer has a unique ID (server ID is always 1)

## Implementation Steps

### 1. Setting Up Multiplayer Connection

```gdscript
# Initialize multiplayer connection
func setup_multiplayer():
    # Create client connection
    var peer = ENetMultiplayerPeer.new()
    peer.create_client("127.0.0.1", 7000)
    multiplayer.multiplayer_peer = peer
    
    # Or create server
    # var peer = ENetMultiplayerPeer.new()
    # peer.create_server(7000, 10)  # port, max_clients
    # multiplayer.multiplayer_peer = peer
```

### 2. Synchronizing Player Positions

The key to making players see each other move is using RPCs to broadcast position updates:

```gdscript
# Player movement function with synchronization
func _process(delta):
    # Handle local player movement
    if Input.is_action_pressed("move_left"):
        position.x -= 200 * delta
    if Input.is_action_pressed("move_right"):
        position.x += 200 * delta
        
    # Send position updates to other players (only on server)
    if multiplayer.is_server():
        update_player_position.rpc(get_global_position())

# RPC function to update other players' positions
@rpc("authority", "call_remote", "reliable")
func update_player_position(position):
    # This function runs on all connected peers
    # Update the position of this specific player
    set_global_position(position)
```

### 3. Complete Player Network Script Example

```gdscript
extends CharacterBody2D

# Player synchronization variables
var player_id = 0
var is_local_player = false

func _ready():
    # Connect to multiplayer signals
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    
    # Set up local player
    if multiplayer.is_server():
        player_id = multiplayer.get_unique_id()
        is_local_player = true
        
        # Setup server-specific logic
        setup_server()
    else:
        # Client logic
        setup_client()

func _process(delta):
    if is_local_player:
        # Handle input and movement
        handle_movement(delta)
        
        # Send position updates to other players (only server should do this)
        if multiplayer.is_server():
            sync_position.rpc(get_global_position())

func handle_movement(delta):
    # Movement logic here
    var direction = Vector2.ZERO
    
    if Input.is_action_pressed("move_left"):
        direction.x -= 1
    if Input.is_action_pressed("move_right"):
        direction.x += 1
        
    velocity = direction * 200
    move_and_slide()

# RPC for position synchronization
@rpc("authority", "call_remote", "reliable")
func sync_position(position):
    # Only clients will receive this call
    if not is_local_player:
        set_global_position(position)

func setup_server():
    # Server-specific setup
    pass

func setup_client():
    # Client-specific setup
    pass

func _on_peer_connected(id):
    print("Player connected: ", id)

func _on_peer_disconnected(id):
    print("Player disconnected: ", id)
```

## RPC Configuration Options

The `@rpc` annotation supports several parameters:

```gdscript
# Basic RPC - calls on all peers except local
@rpc("authority", "call_remote", "reliable", 0)

# Any peer can call - useful for input transfer
@rpc("any_peer", "call_local", "reliable", 0)

# Unreliable ordered - for frequent updates with less reliability
@rpc("authority", "call_remote", "unreliable_ordered", 0)
```

### Parameters:
- **mode**: `"authority"` (server only) or `"any_peer"` (any client can call)
- **sync**: `"call_remote"` (only remote calls) or `"call_local"` (also local)
- **transfer_mode**: `"reliable"`, `"unreliable"`, or `"unreliable_ordered"`
- **transfer_channel**: Channel index for packet separation

## Best Practices

### 1. Position Synchronization Frequency
- Use reliable mode for critical position updates
- Consider unreliable ordered mode for frequent updates to reduce bandwidth usage
- Balance between responsiveness and network efficiency

### 2. Authority Management
```gdscript
# Set authority to server (default)
func set_player_authority():
    # Server has authority over player movement
    set_multiplayer_authority(1)  # 1 is server ID
```

### 3. Error Handling
```gdscript
func handle_network_error(error):
    match error:
        0: print("No error")
        1: print("Connection failed")
        2: print("Connection lost")
        _:
            print("Unknown network error")
```

## Scene Setup Requirements

### Multiplayer Root Node
- The scene root should be configured with multiplayer capabilities
- Use `SceneTree` to manage the networking state

### Node Path Considerations
- All nodes using RPCs must have consistent paths between server and clients
- Node names must match exactly across all instances
- Use `force_readable_name = true` when adding children that will use RPCs

## Security Considerations

### Server Authority Model
- Always validate player inputs on the server
- Never trust client-reported positions directly
- Implement rate limiting for movement updates to prevent cheating

```gdscript
# Server-side validation example
@rpc("any_peer", "call_local", "reliable")
func move_player(input_direction):
    # Validate input before applying
    if is_valid_input(input_direction):
        # Apply movement logic
        apply_movement(input_direction)
```

## Performance Optimization

### 1. Update Rate Control
- Limit position update frequency to prevent network overload
- Use delta time for consistent movement regardless of frame rate

### 2. Network Channels
- Separate critical gameplay data from less important updates
- Use different channels for different types of data

### 3. Data Compression
- Send only necessary position data
- Consider interpolation and extrapolation for smoother movement

## Troubleshooting Common Issues

### 1. RPC Signature Mismatch
Ensure all RPCs are declared identically on both client and server scripts, including:
- Function signatures
- Node paths
- Return types

### 2. Position Synchronization Delays
- Increase transfer mode from unreliable to reliable for critical updates
- Check network connection quality between peers

### 3. Client Disconnection Issues
- Implement proper cleanup functions in `peer_disconnected` signals
- Handle disconnections gracefully without crashing the game

## Testing Your Implementation

1. **Local Testing**: Test with local server and client on same machine
2. **Network Testing**: Test with multiple instances across different machines
3. **Performance Testing**: Monitor network usage and frame rate during gameplay
4. **Security Testing**: Verify that player inputs are properly validated on server

By following these guidelines and using Godot's built-in networking system, you can create multiplayer games where players see each other move in real-time within the same scene.