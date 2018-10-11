import UIKit
import RxSwift

@IBDesignable
class TopView: XibView {

    @IBOutlet private weak var fromView: FromView! { didSet {
        fromView.searchButtonCallback = didTapFromViewSearchButton
        fromView.closeButtonCallback = didTapFromViewCloseButton
    }}
    @IBOutlet private weak var toView: ToView! { didSet {
        toView.searchButtonCallback = didTapToViewSearchButton
        toView.closeButtonCallback = didTapToViewCloseButton
    }}
    @IBOutlet private weak var timeButton: UIButton!
    @IBOutlet private weak var timeButtonContainer: UIStackView!

    private let disposeBag = DisposeBag()
    private var searchResultViewController: SearchResultViewController? {
        didSet {
            searchResultViewController?.didSelectOriginSearchResultCell = didSelectOriginSearchResultCell
            searchResultViewController?.didSelectDestinationSearchResultCell = didSelectDestinationSearchResultCell
        }
    }
    private var mainViewController: MainViewController {
        guard let vc = viewController as? MainViewController else {
            debugErrorPrint(DebugError("Could not get MainViewController.", type: .fatal))
            fatalError()
        }

        return vc
    }

    var addressOriginSearchCallback: ValueCallback<Stop>?
    var addressDestinationSearchCallback: ValueCallback<Stop>?

    var didPressTimeButtonCallback: Callback?

    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.fromView.roundedCorners([.topLeft, .topRight], radius: 8)
            self.toView.roundedCorners([.bottomLeft, .bottomRight], radius: 8)
            self.timeButton.roundedCorners([.bottomRight], radius: 8)
        }
    }

    func viewDidDisappear() {
        guard let searchResultViewController = searchResultViewController else { return }

        if searchResultViewController.searchType == .origin {
            didTapFromViewCloseButton()
        } else if searchResultViewController.searchType == .destination {
            didTapToViewCloseButton()
        }
    }

    private func didTapFromViewSearchButton() {
        fromView.resetButton.fadeOut()
        toView.adjustRight(fullWidth: true)

        fromView.activateSearch()
        toView.deactivateSearch()

        addSearchViewController().activateOriginSearch()
        timeButtonContainer.fadeOut()
    }

    private func didTapFromViewCloseButton() {
        timeButtonContainer.fadeIn()

        if fromView.shouldShowResetButton { fromView.resetButton.fadeIn() }
        toView.adjustRight(fullWidth: false)

        removeSearchViewController()
        fromView.deactivateSearch()
    }

    private func didTapToViewSearchButton() {
        fromView.resetButton.fadeOut()

        fromView.deactivateSearch()
        toView.activateSearch()

        addSearchViewController().activateDestinationSearch()
        timeButtonContainer.fadeOut()
    }

    private func didTapToViewCloseButton() {
        timeButtonContainer.fadeIn()

        if fromView.shouldShowResetButton { fromView.resetButton.fadeIn() }
        toView.adjustRight(fullWidth: false)

        removeSearchViewController()
        toView.deactivateSearch()
    }

    private func didSelectOriginSearchResultCell(model: SearchResultCellModel) {
        if model.stop.type == .address {
            addressOriginSearchCallback?(model.stop)
        } else {
            model.stop.saveCurrentOrigin()
        }

        model.stop.saveSearchedOrigin()
        didTapFromViewCloseButton()
    }

    private func didSelectDestinationSearchResultCell(model: SearchResultCellModel) {
        if model.stop.type == .address {
            addressDestinationSearchCallback?(model.stop)
        } else {
            model.stop.saveCurrentSearch()
        }

        model.stop.saveSearchedDestination()

        toView.prepareSearchedDestinations()
        didTapToViewCloseButton()
    }

    private func addSearchViewController() -> SearchResultViewController {
        if !searchResultViewController.isNil { return searchResultViewController! }

        searchResultViewController = UIStoryboard.main.viewController(ofType: SearchResultViewController.self)
        searchResultViewController!.view.fadeOut()

        mainViewController.add(viewController: searchResultViewController!, position: .underTopView)

        return searchResultViewController!
    }

    private func removeSearchViewController(completion: Callback? = nil) {
        if searchResultViewController.isNil {
            completion?()
            return
        }

        searchResultViewController?.deactivateSearch()
        mainViewController.removeOverlay(viewController: searchResultViewController!, fade: true, completion: {
            self.searchResultViewController = nil
            completion?()
        })
    }

    @IBAction private func didTapTimeButton(_ sender: UIButton) {
        didPressTimeButtonCallback?()
    }
}
