import UIKit

@IBDesignable
class DepartureCellLine: XibView {
    
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var background: UIView!

    func setup(model: DepartureCellModelItem) {
        name.text = model.name
        name.textColor = model.bgColor
        background.backgroundColor = model.fgColor
    }

    func setup(model: LegCellModel) {
        name.font = name.font.withSize(14)
        name.text = model.name
        name.textColor = model.bgColor
        background.backgroundColor = model.fgColor
    }
}
