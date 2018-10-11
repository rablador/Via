import UIKit
import RxSwift

@IBDesignable
class FromView: XibView {

    @IBOutlet private weak var searchInputView: SearchInputView!
    @IBOutlet private weak var fromIcon: UIImageView!
    @IBOutlet private weak var placeholder: UILabel!
    @IBOutlet private weak var searchContainer: UIStackView!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    private let closestOriginsUpdatedObservable: Observable<[Stop]> = PublishSubjects.shared.closestOriginsUpdatedSubject
    private let currentOriginUpdatedObservable: Observable<Stop?> = PublishSubjects.shared.currentOriginUpdatedSubject
    private let disposeBag = DisposeBag()

    private var _shouldShowResetButton = false
    var shouldShowResetButton: Bool {
        get { return _shouldShowResetButton }
        set {
            _shouldShowResetButton = newValue
            newValue ? resetButton.fadeIn() : resetButton.fadeOut()
        }
    }

    var searchButtonCallback: Callback?
    var closeButtonCallback: Callback?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupObservables()
    }

    func activateSearch() {
        searchButton.isEnabled = false

        searchContainer.fadeIn(duration: .fade)
        searchInputView.activate(placeholder: placeholder.text ?? "")
    }

    func deactivateSearch() {
        searchButton.isEnabled = true

        searchContainer.fadeOut(duration: .fade)
        searchInputView.deactivate()
    }

    @IBAction private func resetButtonWasTapped(_ sender: UIButton) {
        Stop.removeCurrentOrigin()
    }

    @IBAction private func searchButtonWasTapped(_ sender: UIButton) {
        searchButtonCallback?()
    }

    @IBAction private func closeButtonWasTapped(_ sender: UIButton) {
        closeButtonCallback?()
    }

    private func setupObservables() {
        currentOriginUpdatedObservable
            .subscribe(onNext: { stop in
                if StopDataHandler.shared.currentOrigin.isNil { return }

                self.shouldShowResetButton = true
                self.fromIcon.image = #imageLiteral(resourceName: "icon_from_stop")
                self.placeholder.text = stop?.name ?? "Söker hållplats..."
            })
            .disposed(by: disposeBag)

        closestOriginsUpdatedObservable
            .subscribe(onNext: { stops in
                guard StopDataHandler.shared.currentOrigin.isNil else { return }

                self.shouldShowResetButton = false
                self.fromIcon.image = #imageLiteral(resourceName: "icon_from")
                self.placeholder.text = stops.first?.name ?? "Söker hållplats..."
            })
            .disposed(by: disposeBag)
    }
}
