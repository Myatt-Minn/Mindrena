# Leaderboard Feature

## Overview
A comprehensive leaderboard system that displays user rankings based on various game statistics from the Firestore `users` collection.

## Features

### 1. Multiple Ranking Filters
- **Total Points**: Ranks users by their total game points
- **Games Won**: Ranks by number of games won
- **Games Played**: Ranks by total games played
- **Win Rate**: Ranks by win percentage
- **Coins**: Ranks by coin balance

### 2. User Interface
- **Modern Design**: Clean, Material Design inspired UI
- **User Header**: Shows current user's rank and stats
- **Search Functionality**: Search players by username or email
- **Filter Chips**: Easy switching between ranking criteria
- **Rank Indicators**: Special icons for top 3 positions (trophy, medals)
- **Motivational Messages**: Encouraging messages based on rank position

### 3. Smart Features
- **Current User Highlighting**: Current user's row is highlighted
- **Rank Colors**: Gold, silver, bronze for top 3 positions
- **Number Formatting**: Large numbers display as K/M format
- **Pull to Refresh**: Refresh leaderboard data
- **Real-time Updates**: Reactive to data changes

### 4. Performance Optimizations
- **Filtered Loading**: Only loads users with game activity
- **Local Search**: Client-side search for better performance
- **Error Handling**: Graceful error handling with user feedback
- **Loading States**: Proper loading indicators

## Technical Implementation

### Data Source
- Fetches data from Firestore `users` collection
- Filters users who have `gamesPlayed > 0` or any stats > 0
- Uses UserModel for type safety

### Controllers
- `LeaderBoardController`: Manages state and business logic
- Reactive variables for real-time UI updates
- Search and filter functionality
- Rank calculation and sorting

### Utilities
- `NumberFormatter`: Extension methods for formatting large numbers
- Color coding based on performance levels
- Motivational messaging system

## Usage

### Navigation
Navigate to leaderboard using the route: `/leader-board`

### API
```dart
// Access the controller
final controller = Get.find<LeaderBoardController>();

// Refresh data
await controller.refreshLeaderboard();

// Change filter
controller.changeFilter('totalPoints');

// Search users
controller.searchController.text = 'username';
```

### Customization
- Modify `filterOptions` to add/remove ranking criteria
- Update `getRankColor()` to change rank color scheme
- Adjust `getMotivationalMessage()` for custom messages

## Dependencies
- `cloud_firestore`: Database queries
- `get`: State management and navigation
- `google_fonts`: Typography
- `get_storage`: Local user data caching

## Files Structure
```
lib/app/modules/leader_board/
├── controllers/
│   └── leader_board_controller.dart
├── views/
│   └── leader_board_view.dart
└── bindings/
    └── leader_board_binding.dart

lib/app/utils/
└── number_formatter.dart
```
