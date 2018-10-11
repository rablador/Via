import UIKit
import DTModelStorage

class FavoriteStopAddCell: UITableViewCell {

    @IBOutlet weak var line: UIView!
}

extension FavoriteStopAddCell: ModelTransfer {

    func update(with model: FavoriteStopAddCellModel) {}
}
