import Foundation
import RxSwift

class StopDataHandler {

    static let shared = StopDataHandler()

    var isSearchDestinationsMode: Bool {
        get { return UserDefaults.standard.bool(forKey: Constants.UserDefaults.isSearchDestinationsMode.rawValue) }
        set { UserDefaults.standard.set(newValue, key: .isSearchDestinationsMode) }
    }

    var favorites = Favorite.all {
        didSet { PublishSubjects.shared.favoritesUpdatedSubject.onNext(favorites) }
    }
    var currentFavorite = Favorite.current {
        didSet {
            PublishSubjects.shared.currentFavoriteUpdatedSubject.onNext(currentFavorite)
            currentDestinations = currentFavorite?.stops
        }
    }

    var commutes = Commute.all {
        didSet { PublishSubjects.shared.commutesUpdatedSubject.onNext(commutes) }
    }

    var currentCommute = Commute.current {
        didSet { PublishSubjects.shared.currentCommuteUpdatedSubject.onNext(currentCommute) }
    }

    var closestOrigins = Stop.closestOrigins {
        didSet { PublishSubjects.shared.closestOriginsUpdatedSubject.onNext(closestOrigins) }
    }
    var searchedOrigins = Stop.searchedOrigins {
        didSet { PublishSubjects.shared.searchedOriginsUpdatedSubject.onNext(searchedOrigins) }
    }
    var searchedDestinations = Stop.searchedDestinations {
        didSet { PublishSubjects.shared.searchedDestinationsUpdatedSubject.onNext(searchedDestinations) }
    }

    var currentOrigin = Stop.currentOrigin {
        didSet {
            if var commute = currentCommute {
                commute.fromStop = currentOrigin
                commute.saveCurrent()
            }
            PublishSubjects.shared.currentOriginUpdatedSubject.onNext(currentOrigin)
        }
    }
    var currentSearches = Stop.currentSearches {
        didSet {
            PublishSubjects.shared.currentSearchesUpdatedSubject.onNext(currentSearches)
            currentDestinations = currentSearches
        }
    }
    var currentDestinations = Stop.currentSearches ?? Favorite.current?.stops {
        didSet {
            if var commute = currentCommute {
                commute.toStops = currentDestinations
                if currentDestinations.isNil { commute.isDeparture = true }
                commute.saveCurrent()
            }
            PublishSubjects.shared.currentDestinationsUpdatedSubject.onNext(currentDestinations)
        }
    }

    var currentTime = Time.current {
        didSet { PublishSubjects.shared.currentTimeUpdatedSubject.onNext(currentTime) }
    }

    private init() {}
}
