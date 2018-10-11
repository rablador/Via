import UIKit
import RxSwift

struct PublishSubjects {

    static let shared = PublishSubjects()

    let favoritesUpdatedSubject = PublishSubject<[Favorite]>()
    let currentFavoriteUpdatedSubject = PublishSubject<Favorite?>()

    let commutesUpdatedSubject = PublishSubject<[Commute]>()
    let currentCommuteUpdatedSubject = PublishSubject<Commute?>()

    let closestOriginsUpdatedSubject = PublishSubject<[Stop]>()
    let searchedOriginsUpdatedSubject = PublishSubject<[Stop]>()
    let searchedDestinationsUpdatedSubject = PublishSubject<[Stop]>()

    let currentOriginUpdatedSubject = PublishSubject<Stop?>()
    let currentSearchesUpdatedSubject = PublishSubject<[Stop]?>()
    let currentDestinationsUpdatedSubject = PublishSubject<[Stop]?>()

    let fetchingDeparturesSubject = PublishSubject<Void>()
    let nearbyStopsSubject = PublishSubject<[Stop]>()
    let searchInputSubject = PublishSubject<String>()

    let infoUpdatedSubject = PublishSubject<DebugError?>()
    let debugInfoUpdatedSubject = PublishSubject<String>()

    let currentTimeUpdatedSubject = PublishSubject<Time>()

    let departuresFetchedSubject = PublishSubject<[DepartureCellModel]>()
    let tripsFetchedSubject = PublishSubject<[TripCellModel]>()

    private init() {}
}
