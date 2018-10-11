import UIKit

class DepartureDetailsBaseView: XibView {

    @IBOutlet internal weak var headerView: DepartureDetailsHeaderView! { didSet {
        headerView.closeButtonCallback = { self.hide() }
    }}
    @IBOutlet internal weak var footerView: DepartureDetailsFooterView!
    @IBOutlet internal weak var dotsView: DepartureDetailsDotsView!
    @IBOutlet internal weak var container: UIView!
    @IBOutlet internal weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet internal weak var fadeView: UIView!
    @IBOutlet internal weak var scrollView: UIScrollView!
    @IBOutlet internal weak var contentContainerView: UIStackView!
    @IBOutlet internal weak var contentContainerWidthConstraint: NSLayoutConstraint!
    
    func show() {
        fadeView.fadeIn(duration: .fast, completion: {
            self.containerTopConstraint.constant = self.container.height
            UIView.animate(duration: .fade, animations: { self.layoutIfNeeded() })
        })
    }

    func hide() {
        containerTopConstraint.constant = -15
        UIView.animate(duration: .fade, animations: { self.layoutIfNeeded() }, completion: {
            self.fadeView.fadeOut(duration: .fast, completion: { self.removeFromSuperview() })
        })
    }

    @IBAction internal func didTap(_ sender: UITapGestureRecognizer) {
        hide()
    }

    internal func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: superview!.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview!.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview!.trailingAnchor).isActive = true
    }

    internal func currentPageIndex() -> Int {
        return Int(scrollView.contentOffset.x / scrollView.width)
    }
}

extension DepartureDetailsBaseView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dotsView.activateDot(index: currentPageIndex())
    }
}
