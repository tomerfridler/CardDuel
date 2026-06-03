import UIKit
import CoreLocation

class MainViewController: UIViewController {

    @IBOutlet weak var main_LBL_greeting: UILabel!
    @IBOutlet weak var main_BTN_setName: UIButton!
    @IBOutlet weak var main_BTN_start: UIButton!
    @IBOutlet weak var main_LBL_sideStatus: UILabel!
    @IBOutlet weak var main_VIEW_leftPanel: UIView!
    @IBOutlet weak var main_VIEW_rightPanel: UIView!

    private let locationService = LocationService()
    private(set) var playerName: String = ""
    private(set) var playerSide: DuelSide?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.clipsToBounds = true
        setupUI()
        setupGlobes()

        if let saved = UserDefaults.standard.string(forKey: "cd_playerName") {
            applyName(saved)
        }

        main_VIEW_leftPanel.isHidden  = true
        main_VIEW_rightPanel.isHidden = true
        main_LBL_sideStatus.text      = ""

        locationService.delegate = self
        locationService.requestAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let status = locationService.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            playerSide = nil
            main_VIEW_leftPanel.isHidden  = true
            main_VIEW_rightPanel.isHidden = true
            main_LBL_sideStatus.text      = ""
            updateStartButton()
            locationService.fetchLocation()
        }
    }

    private func setupUI() {
        main_BTN_start.isEnabled        = false
        main_LBL_greeting.isHidden      = true
        main_BTN_setName.isHidden       = false

        styleBtn(main_BTN_start,   title: "START",      bg: .systemIndigo)
        styleBtn(main_BTN_setName, title: "Insert Name", bg: .systemGray)

        main_LBL_greeting.font = UIFont.boldSystemFont(ofSize: 24)
        main_LBL_sideStatus.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        main_LBL_sideStatus.textColor = .systemIndigo

        main_VIEW_leftPanel.backgroundColor  = UIColor.systemIndigo.withAlphaComponent(0.12)
        main_VIEW_rightPanel.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
    }

    private func styleBtn(_ btn: UIButton, title: String, bg: UIColor) {
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor   = bg
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font  = UIFont.boldSystemFont(ofSize: 18)
    }

    private func setupGlobes() {
        addGlobe(named: "globe-west", alignLeading: true,  labelText: "West Side")
        addGlobe(named: "globe-east", alignLeading: false, labelText: "East Side")
    }

    private func addGlobe(named: String, alignLeading: Bool, labelText: String) {
        let size: CGFloat = 190
        let inset: CGFloat = 25

        let img = UIImageView(image: UIImage(named: named))
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(img)

        if alignLeading {
            img.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset).isActive = true
        } else {
            img.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset).isActive = true
        }
        img.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -15).isActive = true
        img.widthAnchor.constraint(equalToConstant: size).isActive  = true
        img.heightAnchor.constraint(equalToConstant: size).isActive = true

        let lbl = UILabel()
        lbl.text          = labelText
        lbl.font          = UIFont.boldSystemFont(ofSize: 16)
        lbl.textColor     = .systemIndigo
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)

        lbl.centerXAnchor.constraint(equalTo: img.centerXAnchor).isActive     = true
        lbl.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 4).isActive = true
        lbl.widthAnchor.constraint(equalToConstant: size).isActive            = true
    }

    private func applyName(_ name: String) {
        playerName = name
        main_LBL_greeting.text    = "Hello, \(name)!"
        main_LBL_greeting.isHidden = false
        main_BTN_setName.isHidden  = true
        updateStartButton()
    }

    private func updateStartButton() {
        main_BTN_start.isEnabled = !playerName.isEmpty && playerSide != nil
    }


    @IBAction func tappedSetName(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter Name", message: "English letters only", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Your name" ; $0.autocorrectionType = .no }

        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self else { return }
            let raw = alert.textFields?.first?.text ?? ""

            if raw.isEmpty_orWhitespace {
                self.displayToast("Name cannot be empty")
                return
            }
            if !raw.isValidName {
                self.displayToast("English letters only please")
                return
            }
            let clean = String(raw.capitalized.prefix(10))
            UserDefaults.standard.set(clean, forKey: "cd_playerName")
            self.applyName(clean)
        })
        present(alert, animated: true)
    }

    @IBAction func tappedStart(_ sender: UIButton) {
        performSegue(withIdentifier: "showDuel", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDuel" {
            let duel = segue.destination as! DuelViewController
            duel.playerName = playerName
            duel.playerSide = playerSide ?? .west
        }
    }
}

extension MainViewController: LocationServiceDelegate {

    func locationService(_ service: LocationService, didDetermineSide side: DuelSide) {
        playerSide = side

        main_VIEW_leftPanel.isHidden  = true
        main_VIEW_rightPanel.isHidden = true
        main_LBL_sideStatus.text      = "You are on the \(side.rawValue) Side"

        updateStartButton()
    }

    func locationServiceDidFail(_ service: LocationService) {
        displayToast("Could not determine location")
    }
}
