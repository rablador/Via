public typealias JSON = [String: Any]
public typealias SDICT = [String: String]
public typealias Callback = () -> Void
public typealias ValueCallback<T> = (T) -> Void

struct Constants {

    // Brunnsparken: 9021014001760000
    // Stenpiren: 9021014006242000

    // Brunnsparken: 57,7076711, 11,9671093

    enum UserDefaults: String {

        case firstTimeStartup
        case latestLocation

        case favorites
        case currentFavorite

        case currentCommute
        case commutes

        case closestOrigins
        case searchedOrigins
        case searchedDestinations
        case isSearchDestinationsMode
        
        case currentOrigin
        case currentSearches
        case currentDestinations

        case accessToken
        case authScope

        case currentTime
    }

    enum SearchType {

        case origin
        case destination
        case favoriteDestination
    }

    enum OverlayPosition {

        case all
        case underTopView
        case underTimeView
    }

    enum TimeDay: String {

        case monday = "MÅNDAG"
        case tuesday = "TISDAG"
        case wednesday = "ONSDAG"
        case thursday = "TORSDAG"
        case friday = "FREDAG"
        case saturday = "LÖRDAG"
        case sunday = "SÖNDAG"

        static var all: [TimeDay] {
            return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        }
    }

    enum TimeShift: Int {

        case now = 0
        case quarterPast = 15
        case half = 30
        case quarterTo = 45
        case one = 60

        static var all: [TimeShift] {
            return [.now, .quarterPast, .half, .quarterTo, .one]
        }
    }
}
