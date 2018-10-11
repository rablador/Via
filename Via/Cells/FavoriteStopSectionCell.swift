import UIKit
import DTTableViewManager
import DTModelStorage

class FavoriteStopSectionCell: UITableViewCell, DTTableViewManageable {

    @IBOutlet private weak var containerLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var storage: MemoryStorage { return manager.memoryStorage }

    var deleteButtonCallback: Callback?
    var editButtonCallback: Callback?
    var stopDeleteButtonCallback: ValueCallback<Stop>?
    var addStopButtonCallback: Callback?

    override var shouldIndentWhileEditing: Bool {
        get { return false }
        set { self.shouldIndentWhileEditing = false }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        manager.startManaging(withDelegate: self)
        manager.register(FavoriteStopCell.self) { $0.condition = .section(0) }
        manager.register(FavoriteStopAddCell.self) { $0.condition = .section(1) }

        manager.configure(FavoriteStopCell.self) { (cell, model, indexPath) in
            cell.deleteCallback = { self.stopDeleteButtonCallback?(model.stop) }
        }

        manager.configure(FavoriteStopAddCell.self) { (cell, model, indexPath) in
            if let items = self.storage.items(inSection: 0), items.isEmpty { cell.line.fadeOut() }
        }

        manager.didSelect(FavoriteStopAddCell.self) { (cell, model, indexPath) in
            self.addStopButtonCallback?()
        }
    }

    func toggleButtons(show: Bool, animated: Bool = true) {
        containerLeftConstraint.constant = show ? 38 : 0
        editButton.setAlpha(alpha: !show ? .transparent : .opaque, animated: animated, duration: .fade)

        if !animated { return }

        UIView.animate(duration: .slide, animations: { self.contentView.layoutIfNeeded() })
    }

    @IBAction private func didTapDeleteButton(_ sender: UIButton) {
        deleteButtonCallback?()
    }

    @IBAction private func didTapEditButton(_ sender: UIButton) {
        editButtonCallback?()
    }
}

extension FavoriteStopSectionCell: ModelTransfer {

    func update(with model: FavoriteStopSectionCellModel) {
        title.text = model.title
        storage.setItems(model.stops.compactMap { FavoriteStopCellModel(stop: $0) }, forSection: 0)

        if model.stops.count < 3 {
            storage.setItems([FavoriteStopAddCellModel()], forSection: 1)
        }
    }
}
