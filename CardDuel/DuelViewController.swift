import UIKit

class DuelViewController: UIViewController {

    @IBOutlet weak var duel_LBL_playerName: UILabel!
    @IBOutlet weak var duel_LBL_playerScore: UILabel!
    @IBOutlet weak var duel_LBL_opponentName: UILabel!
    @IBOutlet weak var duel_LBL_opponentScore: UILabel!
    @IBOutlet weak var duel_IMG_playerCard: UIImageView!
    @IBOutlet weak var duel_IMG_opponentCard: UIImageView!
    @IBOutlet weak var duel_LBL_playerResult: UILabel!
    @IBOutlet weak var duel_LBL_opponentResult: UILabel!
    @IBOutlet weak var duel_IMG_timerIcon: UIImageView!
    @IBOutlet weak var duel_LBL_timerCount: UILabel!
    @IBOutlet weak var duel_LBL_roundInfo: UILabel!

    var playerName: String = ""
    var playerSide: DuelSide = .west

    private var game    = GameManager()
    private var cdTimer: CountdownTimer?
    private var isActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLabels()
        resetCardDisplay()

        let cfg = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        duel_IMG_timerIcon.image     = UIImage(systemName: "timer", withConfiguration: cfg)
        duel_IMG_timerIcon.tintColor = .systemIndigo

        for v in [duel_LBL_playerName, duel_LBL_playerScore, duel_IMG_playerCard,
                  duel_LBL_playerResult, duel_LBL_opponentName, duel_LBL_opponentScore,
                  duel_IMG_opponentCard, duel_LBL_opponentResult, duel_IMG_timerIcon,
                  duel_LBL_timerCount, duel_LBL_roundInfo] as [UIView] {
            v.translatesAutoresizingMaskIntoConstraints = true
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let w    = view.bounds.width
        let h    = view.bounds.height
        let ins  = view.safeAreaInsets

        let cardW: CGFloat = 150
        let cardH: CGFloat = 200
        let nameH: CGFloat = 22
        let scoreH: CGFloat = 38
        let lx = ins.left + 20
        let rx = w - ins.right - 20 - cardW

        var y = ins.top + 6
        duel_LBL_playerName.frame   = CGRect(x: lx,           y: y, width: 160, height: nameH)
        duel_LBL_opponentName.frame = CGRect(x: rx,           y: y, width: 160, height: nameH)

        y += nameH + 4
        duel_LBL_playerScore.frame   = CGRect(x: lx,          y: y, width: 80, height: scoreH)
        duel_LBL_opponentScore.frame = CGRect(x: rx,          y: y, width: 80, height: scoreH)

        y += scoreH + 6
        duel_IMG_playerCard.frame   = CGRect(x: lx,           y: y, width: cardW, height: cardH)
        duel_IMG_opponentCard.frame = CGRect(x: rx,           y: y, width: cardW, height: cardH)

        let ry = y + cardH + 4
        duel_LBL_playerResult.frame   = CGRect(x: lx,         y: ry, width: cardW, height: 28)
        duel_LBL_opponentResult.frame = CGRect(x: rx,         y: ry, width: cardW, height: 28)

        let timerW: CGFloat = 38
        let timerX = (w - timerW) / 2
        let timerY = (h - timerW) / 2 - 24
        duel_IMG_timerIcon.frame  = CGRect(x: timerX,         y: timerY,          width: timerW, height: timerW)
        duel_LBL_timerCount.frame = CGRect(x: (w - 80) / 2,  y: timerY + timerW + 2, width: 80, height: 46)
        duel_LBL_roundInfo.frame  = CGRect(x: (w - 140) / 2, y: timerY + timerW + 50, width: 140, height: 20)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isActive = true
        startTimer()

        NotificationCenter.default.addObserver(self,
            selector: #selector(appDidBackground),
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(appDidForeground),
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isActive = false
        cdTimer?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appDidBackground() { cdTimer?.cancel() }
    @objc private func appDidForeground() { cdTimer?.continueFromPause() }


    private func configureLabels() {
        if playerSide == .west {
            duel_LBL_playerName.text   = playerName
            duel_LBL_opponentName.text = "PC"
        } else {
            duel_LBL_playerName.text   = "PC"
            duel_LBL_opponentName.text = playerName
        }
        refreshScores()
        updateRoundLabel()

        for lbl in [duel_LBL_playerResult, duel_LBL_opponentResult] {
            lbl?.font          = UIFont.boldSystemFont(ofSize: 22)
            lbl?.textAlignment = .center
            lbl?.isHidden      = true
        }
    }

    private func resetCardDisplay() {
        duel_IMG_playerCard.image   = UIImage(named: "card_back")
        duel_IMG_opponentCard.image = UIImage(named: "card_back")
        duel_LBL_playerResult.isHidden   = true
        duel_LBL_opponentResult.isHidden = true
    }

    private func startTimer() {
        cdTimer = CountdownTimer(delegate: self)
        cdTimer?.begin()
    }


    private func refreshScores() {
        if playerSide == .west {
            duel_LBL_playerScore.text   = "\(game.playerPoints)"
            duel_LBL_opponentScore.text = "\(game.opponentPoints)"
        } else {
            duel_LBL_playerScore.text   = "\(game.opponentPoints)"
            duel_LBL_opponentScore.text = "\(game.playerPoints)"
        }
    }

    private func updateRoundLabel() {
        duel_LBL_roundInfo.text = "Round \(game.roundsCompleted + 1) / \(game.totalRounds)"
    }


    private func resolveRound() {
        guard !game.isGameOver else { goToSummary(); return }
        let result = game.playNextRound()

        // Show the 2 cards face up
        duel_IMG_playerCard.image   = UIImage(named: result.playerCard.assetName)
        duel_IMG_opponentCard.image = UIImage(named: result.opponentCard.assetName)

        showRoundResultText(outcome: result.outcome)
        refreshScores()

        // Wait 3 seconds then move on
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self, self.isActive else { return }
            self.proceedAfterRound()
        }
    }

    private func showRoundResultText(outcome: RoundOutcome) {
        let playerWon  = (outcome == .playerWins)
        let opponentWon = (outcome == .opponentWins)
        let isDraw     = (outcome == .draw)

        duel_LBL_playerResult.isHidden   = false
        duel_LBL_opponentResult.isHidden = false

        if isDraw {
            duel_LBL_playerResult.text   = "Draw"
            duel_LBL_opponentResult.text = "Draw"
            duel_LBL_playerResult.textColor   = .systemOrange
            duel_LBL_opponentResult.textColor = .systemOrange
        } else {
            let playerIsLeft = (playerSide == .west)
            let leftWon  = playerIsLeft ? playerWon : opponentWon
            let rightWon = !leftWon

            duel_LBL_playerResult.text   = leftWon  ? "Win!" : "Lose"
            duel_LBL_opponentResult.text = rightWon ? "Win!" : "Lose"

            duel_LBL_playerResult.textColor   = leftWon  ? .systemGreen : .systemRed
            duel_LBL_opponentResult.textColor = rightWon ? .systemGreen : .systemRed
        }
    }

    private func proceedAfterRound() {
        if game.isGameOver {
            goToSummary()
        } else {
            resetCardDisplay()
            updateRoundLabel()
            startTimer()
        }
    }


    private func goToSummary() {
        performSegue(withIdentifier: "showSummary", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSummary" {
            let summary = segue.destination as! SummaryViewController
            let result  = game.finalResult(playerName: playerName, playerSide: playerSide)
            summary.winnerName  = result.winnerName
            summary.finalScore  = result.winnerScore
        }
    }
}

extension DuelViewController: CountdownTimerDelegate {

    func countdownTimer(_ timer: CountdownTimer, didTick secondsRemaining: Int) {
        duel_LBL_timerCount.text = "\(secondsRemaining)"
    }

    func countdownTimerDidExpire(_ timer: CountdownTimer) {
        resolveRound()
    }
}
