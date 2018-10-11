import UIKit

@IBDesignable
class FavoriteTopView: XibView {

    @IBOutlet private weak var newButton: UIButton!
    @IBOutlet private weak var changeButton: UIButton!
    @IBOutlet private weak var searchContainer: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var searchInputView: SearchInputView!

    var newButtonCallback: Callback?
    var changeButtonCallback: Callback?
    var closeButtonCallback: Callback?

    func toggleNewButton(_ show: Bool) {
        newButton.isEnabled = show
    }

    func toggleChangeButton(_ show: Bool) {
        changeButton.isEnabled = show
    }

    func setChangeButtonTitle(_ title: String) {
        changeButton.setTitle(title, for: .normal)
    }

    func toggleSearch(show: Bool) {
        if show {
            searchContainer.fadeIn(duration: .fade)
            searchInputView.activate(placeholder: "")
        } else {
            searchContainer.fadeOut(duration: .fade)
            searchInputView.deactivate()
        }
    }

    @IBAction private func didTapNewButton(_ sender: UIButton) {
        newButtonCallback?()
    }

    @IBAction private func didTapChangeButton(_ sender: UIButton) {
        changeButtonCallback?()
    }

    @IBAction private func didTapCloseButton(_ sender: UIButton) {
        closeButtonCallback?()
    }
}
