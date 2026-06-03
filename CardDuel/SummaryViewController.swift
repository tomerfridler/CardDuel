import UIKit


class SummaryViewController: UIViewController {

    @IBOutlet weak var summary_LBL_winner: UILabel!
    @IBOutlet weak var summary_LBL_score: UILabel!

    var winnerName: String = ""
    var finalScore: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        populateLabels()
    }

    private func populateLabels() {
        summary_LBL_winner.text = "\(winnerName) Wins!"
        summary_LBL_score.text  = "Final Score: \(finalScore)"

        summary_LBL_winner.font = UIFont.boldSystemFont(ofSize: 32)
        summary_LBL_score.font  = UIFont.systemFont(ofSize: 22)

        summary_LBL_winner.textAlignment = .center
        summary_LBL_score.textAlignment  = .center
    }

    @IBAction func tappedMainMenu(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true)
    }
}
