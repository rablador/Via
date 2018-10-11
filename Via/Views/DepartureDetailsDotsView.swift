import UIKit

@IBDesignable
class DepartureDetailsDotsView: XibView {

    @IBOutlet private weak var container: UIStackView!

    func addDots(count: Int) {
        for _ in 0 ..< count {
            addDotView()
        }
    }

    func removeDots(count: Int) {
        for _ in 0 ..< count {
            removeDotView()
        }
    }

    func activateDot(index: Int) {
        for i in 0 ..< container.arrangedSubviews.count {
            let view = container.arrangedSubviews[i]

            if i == index {
                view.setBackgroundColor(color: .blue6)
            } else {
                view.setBackgroundColor(color: .blue4)
            }
        }
    }

    private func addDotView() {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: height).isActive = true
        view.heightAnchor.constraint(equalToConstant: height).isActive = true

        view.backgroundColor = .blue4
        view.cornerRadius = height / 2

        container.addArrangedSubview(view)
    }

    private func removeDotView() {
        if let view = container.arrangedSubviews.last {
            container.removeArrangedSubview(view)
        }
    }
}
