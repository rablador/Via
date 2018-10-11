import UIKit
import DTModelStorage

class FavoriteStopCell: UITableViewCell {

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!

    var deleteCallback: Callback?

    @IBAction private func didTapButton(_ sender: UIButton) {
        deleteCallback?()
    }
}

extension FavoriteStopCell: ModelTransfer {

    func update(with model: FavoriteStopCellModel) {
        label.text = model.name
        icon.image = model.icon
    }
}
