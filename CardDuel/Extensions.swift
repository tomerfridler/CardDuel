import UIKit

extension UIViewController {

    func displayToast(_ message: String, duration: TimeInterval = 2.0) {

        let bubble = UILabel()
        bubble.text               = message
        bubble.textColor          = .white
        bubble.backgroundColor    = UIColor.black.withAlphaComponent(0.75)
        bubble.textAlignment      = .center
        bubble.font               = .systemFont(ofSize: 14, weight: .medium)
        bubble.numberOfLines      = 0
        bubble.alpha              = 0
        bubble.layer.cornerRadius = 14
        bubble.clipsToBounds      = true

        let horizontalPadding: CGFloat = 48
        let availableWidth = view.frame.width - horizontalPadding * 2
        let fittedSize = bubble.sizeThatFits(
            CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        )

        let verticalOffset: CGFloat = 110
        let verticalPadding: CGFloat = 20
        bubble.frame = CGRect(
            x:      horizontalPadding,
            y:      view.frame.height - fittedSize.height - verticalOffset,
            width:  availableWidth,
            height: fittedSize.height + verticalPadding
        )

        view.addSubview(bubble)

        UIView.animate(withDuration: 0.3) {
            bubble.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut) {
                bubble.alpha = 0
            } completion: { _ in
                bubble.removeFromSuperview()
            }
        }
    }
}

extension String {

    
    var isEmpty_orWhitespace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isValidName: Bool {
        guard !isEmpty else { return false }
        return range(of: #"^[A-Za-z ]+$"#, options: .regularExpression) != nil
    }
}
