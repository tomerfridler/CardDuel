# CardDuel 🃏

An iOS card game for two players that uses real-time location to assign each player to the **West Side** or **East Side** before the game begins.

## About the App

CardDuel is a two-player card duel game built in Swift using UIKit.  
Each player sits on one side of a reference point — west or east — determined automatically by GPS location.  
The game runs for 10 rounds. Each round, a countdown timer flips two random cards and the higher card wins the point. At the end of 10 rounds, the player with the most points wins.

## How to Play

1. Launch the app and tap **Insert Name** to enter your name
2. The app detects your location and assigns you to **West Side** or **East Side**
3. Tap **START** to begin
4. Each round counts down from 5 seconds — when the timer hits zero, two cards are revealed
5. The higher card wins the round point
6. After 10 rounds, the winner is displayed on the summary screen

## Features

- Location-based side assignment (West / East) using CoreLocation
- 52-card deck with random draws each round
- 10-round game with live score tracking
- Countdown timer with background/foreground handling
- Winner summary screen at the end of the game
- Player name saved between sessions

## Project Structure

| File | Description |
|---|---|
| `MainViewController.swift` | Home screen — name input, location detection, start button |
| `DuelViewController.swift` | Game screen — cards, timer, scores, round display |
| `SummaryViewController.swift` | End screen — winner and final score |
| `GameManager.swift` | All game logic — deck, scoring, round results |
| `CountdownTimer.swift` | Countdown timer with pause/resume support |
| `LocationService.swift` | CoreLocation wrapper — determines West or East side |
| `Extensions.swift` | Shared UI helpers and String validation |

## Technologies

- Swift
- UIKit
- CoreLocation
- UserDefaults

## Requirements

- iOS 15+
- Xcode 14+
- Location permission required
