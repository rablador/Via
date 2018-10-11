import UIKit
import DTModelStorage

class AlarmCell: UITableViewCell {

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var label: UILabel!
}

extension AlarmCell: ModelTransfer {

    func update(with model: AlarmCellModel) {
        label.text = model.name
        icon.image = model.icon
    }
}
