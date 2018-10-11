import UIKit
import RxSwift

protocol CollectionViewBaseProtocol {

    func fetchingDepartures()
}

class CollectionViewBase: XibView, CollectionViewBaseProtocol {

    @IBOutlet weak var collectionView: UICollectionView?

    internal let fetchingDeparturesObservable: Observable = PublishSubjects.shared.fetchingDeparturesSubject
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupObservables()
    }

    func fetchingDepartures() {}

    func updateItemPositions(allIndices: [Int], visibleIndices: [Int], currentIndex: Int, leftModifier: Int = 6, rightModifier: Int = 6, animated: Bool = true) {
        guard let collectionView = collectionView else { return }
        guard !allIndices.isEmpty, !visibleIndices.isEmpty else { return }

        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        guard let cellLayout = collectionView.layoutAttributesForItem(at: currentIndexPath) else { return }

        let leftModifier = CGFloat(leftModifier)
        let rightModifier = CGFloat(rightModifier)

        let leftPosition = cellLayout.frame.origin.x
        let rightPosition = cellLayout.frame.origin.x + cellLayout.frame.size.width

        if visibleIndices.contains(currentIndex) {
            let isHalfVisibleLeft = leftPosition < (collectionView.contentOffset.x + leftModifier)
            let isHalfVisibleRight = rightPosition > (collectionView.contentOffset.x + collectionView.width - rightModifier)

            if isHalfVisibleLeft || isHalfVisibleRight {
                let rect = CGRect(origin: CGPoint(x: cellLayout.frame.origin.x - (isHalfVisibleRight ? -rightModifier : leftModifier), y: cellLayout.frame.origin.y), size: cellLayout.frame.size)
                collectionView.scrollRectToVisible(rect, animated: animated)
            }
        } else {
            guard !visibleIndices.first.isNil, let firstVisibleIndex = allIndices.index(of: visibleIndices.first!) else { return }

            let rect = CGRect(origin: CGPoint(x: cellLayout.frame.origin.x - (currentIndex > firstVisibleIndex ? -rightModifier : leftModifier), y: cellLayout.frame.origin.y), size: cellLayout.frame.size)
            collectionView.scrollRectToVisible(rect, animated: animated)
        }
    }

    func scrollToFirstItem(leftModifier: Int = 0, animated: Bool = true) {
        guard let collectionView = collectionView else { return }

        let indexPath = IndexPath(item: 0, section: 0)
        guard let cellLayout = collectionView.layoutAttributesForItem(at: indexPath) else { return }

        let rect = CGRect(origin: CGPoint(x: cellLayout.frame.origin.x - CGFloat(leftModifier), y: cellLayout.frame.origin.y), size: cellLayout.size)
        collectionView.scrollRectToVisible(rect, animated: animated)
    }

    private func setupObservables() {
        fetchingDeparturesObservable
            .subscribe(onNext: { self.fetchingDepartures() })
            .disposed(by: disposeBag)
    }
}
