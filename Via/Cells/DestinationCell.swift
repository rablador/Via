import UIKit
import DTModelStorage

class DestinationCell: UICollectionViewCell {

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var contentContainer: UIStackView!
    @IBOutlet private weak var searchButton: UIImageView!
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!

    var model: FavoriteCellModelItem!

    func set(selected: Bool, animated: Bool = true) {
        if model.isSearchButton { return }

        setBackgroundColor(color: selected ? .blue5 : .clear, duration: animated ? .fade : .now)
        name.setTextColor(color: selected ? .blue1 : .blue5, duration: animated ? .fade : .now)
    }
}

extension DestinationCell: ModelTransfer {

    func update(with model: FavoriteCellModelItem) {
        self.model = model

        if model.isSearchButton {
            searchButton.isHidden = false
            contentContainer.isHidden = true
            leftConstraint.constant = 0

            setBackgroundColor(color: .clear)

            return
        }

        searchButton.isHidden = true
        contentContainer.isHidden = false
        leftConstraint.constant = 8

        icon.isHidden = !model.isSearch
        name.text = model.name

        setBackgroundColor(color: model.isSearch ? .blue5 : .clear)
        name.setTextColor(color: model.isSearch ? .blue1 : .blue5)
    }
}
