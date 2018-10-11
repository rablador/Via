import Foundation
import CoreLocation
import RxMoya
import Moya
import RxSwift
import PromiseKit

struct VasttrafikService {

    static let shared = VasttrafikService()

    @discardableResult
    func getAccessToken() -> Observable<AccessToken> {
        return VasttrafikProvider.shared.rx
            .request(.accessToken())
            .parseAuthResponse()
            .mapObject(type: AccessToken.self)
            .do(onNext: { $0.save() })
    }

    @discardableResult
    func getNearbyStops(location: CLLocation) -> Observable<[Stop]> {
        return VasttrafikProvider.shared.rx
            .request(.nearbyStops(location: location))
            .parseApiResponse()
            .mapArray(type: Stop.self)
    }

    @discardableResult
    func getNearbyStops() -> Observable<[Stop]> {
        return LocationHandler.shared.update()
            .flatMap { location -> Observable<[Stop]> in
//                debugPrint(location)
//                debugPrint(location.needsUpdate)

                let locationNeedsUpdating = location.needsUpdate
                if locationNeedsUpdating { location.saveLatest() }

//                if locationNeedsUpdating || StopDataHandler.shared.closestOrigins.isEmpty {
                if true {
                    return VasttrafikProvider.shared.rx
                        .request(.nearbyStops(location: location))
                        .parseApiResponse()
                        .mapArray(type: Stop.self)
                        .do(onNext: { $0.saveClosestOrigins() })
                } else {
//                    PublishSubjects.shared.closestOriginsUpdatedSubject.onNext(StopDataHandler.shared.closestOrigins)
//                    return Observable.just(StopDataHandler.shared.closestOrigins)
                }
            }
    }

    @discardableResult
    func getDepartures(at date: Date, origin: Stop? = nil) -> Observable<[Departure]> {
        if let stop = origin {
            return Observable.from([stop])
                .flatMap { self.getTimeAdjustedDepartures(date: date, origin: $0) }
        } else {
            return getNearbyStops()
                .flatMap { Observable.from(!$0.isEmpty ? [$0.first!] : $0) }
                .flatMap { self.getTimeAdjustedDepartures(date: date, origin: $0) }
        }
    }

    @discardableResult
    func getTrips(at date: Date, origin: Stop? = nil, destinations: [Stop], isDeparture: Bool) -> Observable<[Trip]> {
        var originsAndDestinations = [(Stop, Stop)]()

        if let origin = origin {
            destinations.forEach { originsAndDestinations.append((origin, $0)) }

            return Observable.from(originsAndDestinations)
                .flatMap { self.getTimeAdjustedTrips(date: date, origin: $0.0, destination: $0.1, isDeparture: isDeparture) }
        } else {
            return getNearbyStops()
                .flatMap { Observable.from(!$0.isEmpty ? [$0.first!] : $0) }
                .map { stop in destinations.forEach { originsAndDestinations.append((stop, $0)) } }
                .flatMap { Observable.from(originsAndDestinations) }
                .flatMap { self.getTimeAdjustedTrips(date: date, origin: $0.0, destination: $0.1, isDeparture: isDeparture) }
        }
    }

    @discardableResult
    func searchStops(searchString: String) -> Observable<[Stop]> {
        return VasttrafikProvider.shared.rx
            .request(.searchStops(searchString: searchString))
            .parseApiResponse()
            .mapArray(type: Stop.self)
    }

    @discardableResult
    func getJourneyDetail(ref: String) -> Observable<JourneyDetail> {
        return VasttrafikProvider.shared.rx
            .request(.journeyDetail(ref: ref))
            .parseApiResponse()
            .mapObject(type: JourneyDetail.self)
    }
}

extension VasttrafikService {

    private func getTimeAdjustedDepartures(date: Date, origin: Stop) -> Observable<[Departure]> {
        return Observable
            .merge([
                _getDepartures(date: date.inFuture(mins: -5), timeSpan: 10, origin: origin),
                _getDepartures(date: date.inFuture(mins: 5), timeSpan: 90, origin: origin)
            ])
    }

    private func getTimeAdjustedTrips(date: Date, origin: Stop, destination: Stop, isDeparture: Bool) -> Observable<[Trip]> {
        return Observable
            .merge([
                _getTrips(date: date.inFuture(mins: -5), origin: origin, destination: destination, isDeparture: isDeparture),
                _getTrips(date: date, origin: origin, destination: destination, isDeparture: isDeparture)
            ])
    }
}

extension VasttrafikService {

    @discardableResult
    private func _getDepartures(date: Date, timeSpan: Int, origin: Stop) -> Observable<[Departure]> {
        return VasttrafikProvider.shared.rx
            .request(.departures(date: date, timeSpan: timeSpan, origin: origin))
            .parseApiResponse()
            .mapArray(type: Departure.self)
    }

    @discardableResult
    private func _getTrips(date: Date, origin: Stop, destination: Stop, isDeparture: Bool) -> Observable<[Trip]> {
        return VasttrafikProvider.shared.rx
            .request(.trips(date: date, origin: origin, destination: destination, isDeparture: isDeparture))
            .parseApiResponse()
            .mapArray(type: Trip.self)
    }
}
