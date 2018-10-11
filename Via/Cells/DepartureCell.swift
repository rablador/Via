import UIKit
import DTModelStorage

class DepartureCell: UITableViewCell {

    @IBOutlet private weak var direction: UILabel!
    @IBOutlet private weak var lineView: DepartureCellLine!
    @IBOutlet private weak var timeView: DepartureCellTime!
    @IBOutlet private weak var transfers: UIStackView!
    @IBOutlet private weak var line: UIView!

    private func addTransferViews(model: TripCellModel) {
        let transferCount = model.transfers.count

        if transferCount > 0 {
            let transfer = model.transfers[0]
            let transferView = transfers.subviews[1] as! TransferView

            transferView.setup(leg: transfer)
            transferView.isHidden = false
        }

        if transferCount > 2 {
            let surplus = transferCount - 1
            let transferView = transfers.subviews[2] as! TransferView

            transferView.name.text = "+\(surplus)"
            transferView.name.textColor = .blue1
            transferView.background.backgroundColor = .blue4

            transferView.isHidden = false
        } else if transferCount == 2 {
            let transfer = model.transfers[1]
            let transferView = transfers.subviews[2] as! TransferView

            transferView.setup(leg: transfer)
            transferView.isHidden = false
        }

        addTransferEndView(leg: model.transfers.last!)
    }

    private func addTransferEndView(leg: Leg) {
        let transferEndView = transfers.subviews.last! as! TransferEndView
        transferEndView.setup(leg: leg)
        transferEndView.isHidden = false
    }
}

extension DepartureCell: ModelTransfer {

    func update(with model: DepartureCellModelItem) {
        direction.text = model.direction

        lineView.setup(model: model)
        timeView.setup(model: model)

        transfers.isHidden = true
        line.isHidden = true

        if let model = model as? TripCellModel {
            transfers.subviews.forEach { $0.isHidden = true }
            transfers.isHidden = false

            if !model.transfers.isEmpty {
                addTransferViews(model: model)
            } else {
                line.isHidden = false
                addTransferEndView(leg: model.legs!.first!)
            }
        }
    }
}
