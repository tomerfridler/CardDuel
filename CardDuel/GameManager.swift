import Foundation

struct PlayingCard {
    let assetName: String
    let rank: Int
}

enum RoundOutcome {
    case playerWins
    case opponentWins
    case draw
}

class GameManager {

    // Total num of rounds before the game ends
    let totalRounds = 10

    private(set) var playerPoints   = 0
    private(set) var opponentPoints = 0

    // How many rounds have been completed so far
    private(set) var roundsCompleted = 0

    // True when all rounds have been played
    var isGameOver: Bool { roundsCompleted >= totalRounds }

    
    // All 52 cards built once at launch
    private let fullDeck: [PlayingCard] = {
        let spades: [(String, Int)] = [
            ("card_s_ace", 14), ("card_s_2", 2), ("card_s_3", 3), ("card_s_4", 4),
            ("card_s_5", 5),    ("card_s_6", 6), ("card_s_7", 7), ("card_s_8", 8),
            ("card_s_9", 9),    ("card_s_10", 10), ("card_s_j", 11), ("card_s_q", 12), ("card_s_k", 13)
        ]
        let hearts: [(String, Int)] = [
            ("card_h_ace", 14), ("card_h_2", 2), ("card_h_3", 3), ("card_h_4", 4),
            ("card_h_5", 5),    ("card_h_6", 6), ("card_h_7", 7), ("card_h_8", 8),
            ("card_h_9", 9),    ("card_h_10", 10), ("card_h_j", 11), ("card_h_q", 12), ("card_h_k", 13)
        ]
        let clubs: [(String, Int)] = [
            ("card_c_ace", 14), ("card_c_2", 2), ("card_c_3", 3), ("card_c_4", 4),
            ("card_c_5", 5),    ("card_c_6", 6), ("card_c_7", 7), ("card_c_8", 8),
            ("card_c_9", 9),    ("card_c_10", 10), ("card_c_j", 11), ("card_c_q", 12), ("card_c_k", 13)
        ]
        let diamonds: [(String, Int)] = [
            ("card_d_ace", 14), ("card_d_2", 2), ("card_d_3", 3), ("card_d_4", 4),
            ("card_d_5", 5),    ("card_d_6", 6), ("card_d_7", 7), ("card_d_8", 8),
            ("card_d_9", 9),    ("card_d_10", 10), ("card_d_j", 11), ("card_d_q", 12), ("card_d_k", 13)
        ]
        return (spades + hearts + clubs + diamonds).map {
            PlayingCard(assetName: $0.0, rank: $0.1)
        }
    }()


    func playNextRound() -> (playerCard: PlayingCard, opponentCard: PlayingCard, outcome: RoundOutcome) {
        let playerCard   = fullDeck.randomElement()!
        let opponentCard = fullDeck.randomElement()!

        let outcome: RoundOutcome
        if playerCard.rank > opponentCard.rank {
            playerPoints += 1
            outcome = .playerWins
        } else if opponentCard.rank > playerCard.rank {
            opponentPoints += 1
            outcome = .opponentWins
        } else {
            // Equal ranks — neither side scores
            outcome = .draw
        }

        roundsCompleted += 1
        return (playerCard, opponentCard, outcome)
    }


    // Compares totals and returns the winners desplat name and score
    func finalResult(playerName: String, playerSide: DuelSide) -> (winnerName: String, winnerScore: Int) {
        if playerPoints > opponentPoints {
            // Player won
            return (playerName, playerPoints)
        } else if opponentPoints > playerPoints {
            // CP won
            return ("PC", opponentPoints)
        } else {
            // Tie = Player won
            return (playerName, playerPoints)
        }
    }
}
