import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var grabberView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)

        if isiPhoneX {
            containerTopConstraint.constant = 0
            containerBottomConstraint.constant = -24
            grabberView.isHidden = false
        }
    }
}

extension StartViewController {

    @objc private func appBecameActive(notification: Notification) {
        PublishSubjects.shared.currentOriginUpdatedSubject.onNext(StopDataHandler.shared.currentOrigin)
        PublishSubjects.shared.currentSearchesUpdatedSubject.onNext(StopDataHandler.shared.currentSearches)
        PublishSubjects.shared.favoritesUpdatedSubject.onNext(StopDataHandler.shared.favorites)
        PublishSubjects.shared.currentTimeUpdatedSubject.onNext(StopDataHandler.shared.currentTime)
        PublishSubjects.shared.currentCommuteUpdatedSubject.onNext(StopDataHandler.shared.currentCommute)
    }

    @objc private func appEnteredBackground(notification: Notification) {}
}
