import Alamofire
import RxSwift

class ReachabilityHandler {

    static let shared = ReachabilityHandler()

    private let reachability = NetworkReachabilityManager()
    private let _didBecomeReachable = PublishSubject<NetworkReachabilityManager.NetworkReachabilityStatus>()

    var didBecomeReachable: Observable<NetworkReachabilityManager.NetworkReachabilityStatus> {
        return _didBecomeReachable
            .asObservable()
            .catchErrorJustReturn(.unknown)
    }

    private init() {
        if let reachability = reachability {
            reachability.listener = { [unowned self] in self._didBecomeReachable.onNext($0) }
            reachability.startListening()
        }
    }
}
