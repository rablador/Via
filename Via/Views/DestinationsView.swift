import UIKit
import DTCollectionViewManager
import DTModelStorage

class DestinationsView: CollectionViewBase, DTCollectionViewManageable {

    var favoriteCellModelItems = [FavoriteCellModelItem]() {
        didSet { storage.setItems(favoriteCellModelItems) }
    }

    var storage: MemoryStorage { return manager.memoryStorage }

    override func awakeFromNib() {
        super.awakeFromNib()

        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 28)
        }

        manager.startManaging(withDelegate: self)
        manager.register(DestinationCell.self)
    }
}
