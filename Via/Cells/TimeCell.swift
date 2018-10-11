import UIKit
import DTModelStorage

class TimeCell: UICollectionViewCell {

    @IBOutlet private weak var title: UILabel!

    var model: TimeCellModel!

    func set(selected: Bool, animated: Bool = true) {
        setBackgroundColor(color: selected ? .blue5 : .clear, duration: animated ? .fade : .now)
        title.setTextColor(color: selected ? .blue1 : .blue5, duration: animated ? .fade : .now)
    }
}

extension TimeCell: ModelTransfer {

    func update(with model: TimeCellModel) {
        self.model = model
        title.text = model.title
    }
}
