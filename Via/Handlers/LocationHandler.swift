//
//  GeolocationService.swift
//  RxExample
//
//  Created by Carlos García on 19/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

//  Modified by Jon Petersson on 02/01/18 (and onwards).

import CoreLocation
import RxSwift
import RxCocoa

class LocationHandler {

    static let shared = LocationHandler()

    private (set) var authorized: Observable<Bool>
    private (set) var location: Observable<CLLocation>
    private let locationManager = CLLocationManager()
    private let disposeBag = DisposeBag()

    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        authorized = Observable
            .deferred { [weak locationManager] in
                let status = CLLocationManager.authorizationStatus()
                guard let locationManager = locationManager else { return Observable.just(status) }
                return locationManager.rx.didChangeAuthorizationStatus.startWith(status)
            }
            .catchErrorJustReturn(CLAuthorizationStatus.notDetermined)
            .map { $0 == .authorizedWhenInUse ? true : false }

        location = locationManager.rx.didUpdateLocations
            .take(1)
            .catchError { Observable.error(DebugError($0.localizedDescription, type: .location)) }
            .flatMap { $0.last.map(Observable.just) ?? Observable.empty() }

        locationManager.requestWhenInUseAuthorization()
        update()
    }

    @discardableResult
    func update() -> Observable<CLLocation> {
        locationManager.startUpdatingLocation()

        location
            .subscribe(onNext: { [unowned self] _ in self.locationManager.stopUpdatingLocation() })
            .disposed(by: disposeBag)

        return location
    }
}
