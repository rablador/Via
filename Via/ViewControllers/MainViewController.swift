import UIKit
import RxSwift

class MainViewController: UIViewController {

    @IBOutlet private weak var statusBarMaskingView: UIView!
    @IBOutlet private weak var topView: TopView!
    @IBOutlet private weak var timeView: TimeView!

    private var departureViewController: DepartureViewController!

    private var debugView: DebugView?
    private let debugInfoUpdatedObservable: Observable<String> = PublishSubjects.shared.debugInfoUpdatedSubject
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        departureViewController = UIStoryboard.main.viewController(ofType: DepartureViewController.self)
        add(viewController: departureViewController, position: .underTimeView)

        topView.addressOriginSearchCallback = { self.departureViewController.searchAddressStops(address: $0, isDestination: false) }
        topView.addressDestinationSearchCallback = { self.departureViewController.searchAddressStops(address: $0) }
        topView.didPressTimeButtonCallback = { self.timeView.toggle() }

        if isDebug { addDebugView() }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topView.viewDidDisappear()
    }

    func add(viewController: UIViewController, position: Constants.OverlayPosition) {
        addChild(viewController)
        viewController.didMove(toParent: self)

        if viewController.isKind(of: DepartureViewController.self) {
            view.insertSubview(viewController.view, at: 0)
        } else {
            view.addSubview(viewController.view)
        }

        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        let topAnchor: NSLayoutYAxisAnchor

        switch position {
        case .all:
            topAnchor = statusBarMaskingView.bottomAnchor
        case .underTopView:
            topAnchor = topView.bottomAnchor
        case .underTimeView:
            topAnchor = timeView.bottomAnchor
        }

        viewController.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: isiPhoneX ? -2 : -15).isActive = true
        viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func addDebugView() {
        let height = view.height / 3
        debugView = DebugView(frame: CGRect(x: 0, y: view.bottom - height, width: view.width, height: height))
        debugView?.fadeOut()
        view.addSubview(debugView!)

        let button = UIButton(frame: CGRect(x: 0, y: view.bottom - 30, width: view.width, height: 30))
        button.addTarget(self, action: #selector(didTapDebugButton), for: .touchUpInside)
        view.addSubview(button)

        debugInfoUpdatedObservable
            .subscribe(onNext: { self.debugView?.set(text: $0) })
            .disposed(by: disposeBag)
    }

    @objc private func didTapDebugButton() {
        if let debugView = debugView {
            debugView.isVisible ? debugView.fadeOut() : debugView.fadeIn()
        }
    }
}
