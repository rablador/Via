import UIKit
import DTModelStorage

class SearchResultCell: UITableViewCell {
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var labelSuffix: UILabel!
}

extension SearchResultCell: ModelTransfer {

    func update(with model: SearchResultCellModel) {
        label.text = model.name
        labelSuffix.text = model.city
        icon.image = model.icon
    }
}
