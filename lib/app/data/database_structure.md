users (collection)
  └── {userId} (document)
        ├── username: string
        ├── email: string
        ├── avatarUrl: string
        ├── currentGameId: string (nullable)
        ├── stats: map
              ├── gamesPlayed: int
              ├── gamesWon: int
              └── totalPoints: int

games (collection)
  └── {gameId} (document)
        ├── playerIds: array[string]        // [player1Id, player2Id]
        ├── playerStates: map               // {player1Id: "ready", player2Id: "waiting", ...}
        ├── currentQuestionIndex: int
        ├── questions: array[map]           // [{questionText, options, correctIndex, ...}, ...]
        ├── answers: map
        │     ├── {playerId}: array[int]    // Each player's answers (index of selected option)
        ├── scores: map
        │     ├── {playerId}: int           // Each player's score
        ├── startedAt: timestamp
        ├── finishedAt: timestamp (nullable)
        ├── status: string                  // waiting, active, finished

questions (collection)     // Optional: If you want a question bank
  └── {questionId} (document)
        ├── text: string
        ├── options: array[string]
        ├── correctIndex: int
        ├── category: string

matchmaking (collection)   // For finding/joining games
  └── {entryId} (document)
        ├── userId: string
        ├── requestedAt: timestamp
        ├── status: string                  // waiting, matched, expired