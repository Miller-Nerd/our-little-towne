# Multiplayer Implementation Guide

This document outlines the multiplayer system implementation for Our Little Towne, providing guidelines for consistent development and future reference.

## Overview

The game implements a client-server multiplayer system using Godot's ENetMultiplayerPeer with a lobby-based architecture. The system supports up to 8 players connecting to a single server.

## Core Components

### NetworkManager.gd
- Central network management node
- Handles server creation and client connections
- Manages player lobby state and communication
- Implements RPC functions for lobby operations:
  - Player joining/leaving
  - Ready status changes
  - Game start requests
- Uses `@rpc("any_peer", "reliable")` for important operations

### ConnectionAttempt.gd
- Handles client connection process
- Manages connection timeouts and error states
- Provides UI feedback during connection
- Supports both local and remote server connections

## Architecture

### Client-Server Model
- Server (host) has player ID 1
- Clients receive random positive integer IDs
- All communication goes through the host for lobby management

### Connection Flow
1. Client connects to server using ENetMultiplayerPeer
2. Connection validated with timeout checks
3. Player data sent to lobby system via RPC
4. Lobby state synchronized to all connected players

## Best Practices Implemented

### RPC Usage
- Use `@rpc("any_peer", "reliable")` for important lobby operations
- All RPC functions must be defined on both server and client scripts
- Ensure matching signatures between server and client implementations

### Error Handling
- Connection timeouts with retry logic
- Proper cleanup of multiplayer peers
- Error reporting through print statements

### Data Management
- Player data stored as dictionaries with name and ready status
- Lobby state synchronized across all connected peers
- Validation of player IDs before processing operations

## Security Considerations

⚠️ **Important**: The current implementation lacks:
- Authentication mechanisms
- Data validation for received information
- Encryption for sensitive communications
- Rate limiting for RPC calls

These should be implemented before production release.

## Scalability Notes

### Current Limitations
- Maximum players fixed at 8
- No dynamic scaling support
- Single lobby architecture

### Future Improvements
- Implement dynamic player count management
- Add lobby creation/deletion functionality
- Support multiple concurrent game sessions

## Development Guidelines

### Adding New RPC Functions
1. Always use `@rpc("any_peer", "reliable")` for lobby operations
2. Define the function on both server and client scripts
3. Ensure matching signatures between implementations
4. Include proper error handling in implementations

### Connection Management
- Always clean up multiplayer peers properly
- Implement timeout checks during connection process
- Handle disconnection events gracefully

### Testing Considerations
- Test with multiple clients connecting simultaneously
- Verify lobby state synchronization across all players
- Check that player removal works correctly when clients disconnect