import UIKit
import RxSwift
import DTTableViewManager
import DTModelStorage

class DepartureDetailsContentBaseView: XibView, DTTableViewManageable {

    @IBOutlet internal weak var infoLabel: UILabel!
    @IBOutlet internal weak var tableView: UITableView!

    internal let currentOriginUpdatedObservable: Observable<Stop?> = PublishSubjects.shared.currentOriginUpdatedSubject
    internal let currentDestinationsUpdatedObservable: Observable<[Stop]?> = PublishSubjects.shared.currentDestinationsUpdatedSubject

    internal let disposeBag = DisposeBag()
    internal var storage: MemoryStorage { return manager.memoryStorage }
    internal var currentOrigin: Stop?
    
    var hideCallback: Callback?
}
