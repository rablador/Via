import UIKit
import RxSwift

@IBDesignable
class ToView: XibView {

    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var searchesView: SearchesView!
    @IBOutlet private weak var searchInputView: SearchInputView!
    @IBOutlet private weak var searchContainer: UIStackView!
    @IBOutlet private weak var searchesViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var favoritesView: FavoritesView! { didSet {
        favoritesView.searchButtonCallback = { self.searchButtonCallback?() }
    }}

    var searchButtonCallback: Callback?
    var closeButtonCallback: Callback?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func activateSearch() {
        searchInputView.activate(placeholder: "")
        searchContainer.fadeIn(duration: .fade)
    }

    func deactivateSearch() {
        searchInputView.deactivate()
        searchContainer.fadeOut(duration: .fade)
    }

    func prepareSearchedDestinations() {
        searchesView.fadeIn(duration: .fade)
    }

    func adjustRight(fullWidth: Bool) {
        searchesViewRightConstraint.constant = fullWidth ? 0 : 56
    }

    func showInputKeyboard() {
        searchInputView.showKeyboard()
    }

    func hideInputKeyboard() {
        searchInputView.hideKeyboard()
    }

    @IBAction private func searchButtonPressed(_ sender: UIButton) {
        searchButtonCallback?()
    }

    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        closeButtonCallback?()
    }
}
