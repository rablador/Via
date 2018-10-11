import UIKit
import DTTableViewManager
import DTModelStorage

class AlarmViewController: UIViewController, DTTableViewManageable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var infoLabel: InfoLabel!

    private var storage: MemoryStorage { return manager.memoryStorage }

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.startManaging(withDelegate: self)
        manager.register(AlarmCell.self)

        manager.configure(AlarmCell.self) { (cell, model, indexPath) in
            cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? .blue2 : .blue1
        }

//        manager.didSelect(AlarmCell.self) { [unowned self] (cell, model, indexPath) in
//            // Todo
//        }
    }
}
