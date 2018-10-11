import UIKit
import DTModelStorage

class SearchResultSectionHeader: UIView {

    @IBOutlet private weak var title: UILabel!
}

extension SearchResultSectionHeader: ModelTransfer {

    func update(with model: SearchResultSectionHeaderModel) {
        title.text = model.title
    }
}
