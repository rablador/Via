struct SortHandler {

    static let shared = SortHandler()

    private init() {}

    func aggregateDepartures(departures: [Departure]) -> [DepartureCellModel] {
        var aggregatedDepartures = [String: [Departure]]()

        // Order on time left.
        let sortedDepartures = sort(departures: departures)

        for departure in sortedDepartures {
            // Don't add departed departures.
            if departure.timeLeft < 0 {
                continue
            }

            // Check already aggregated departures.
            var existingDepartures = [Departure]()
            if let departures = aggregatedDepartures[departure.filterId] {
                existingDepartures = departures
            }

            // Always add first departure.
            if existingDepartures.isEmpty {
                aggregatedDepartures[departure.filterId] = [departure]
                continue
            }

            // Don't add duplicates.
            if !existingDepartures.filter({ $0.journeyId == departure.journeyId }).isEmpty {
                continue
            }

            // Add departure.
            existingDepartures.append(departure)

            // Update aggregated departures.
            aggregatedDepartures[departure.filterId] = existingDepartures
        }

        return sort(aggregatedDepartures: aggregatedDepartures).map { DepartureCellModel(departures: $0.1) }
    }

    func aggregateTrips(trips: [Trip]) -> [TripCellModel] {
        var aggregatedTrips = [String: [Trip]]()

        // Order on time left.
        let sortedTrips = sort(trips: trips)

        for trip in sortedTrips {
            // Don't add departed trips.
            if trip.legs.first!.origin.timeLeft < 0 {
                continue
            }

            // Make sure the trip is valid.
            guard trip.valid else { continue }

            // Check already aggregated trips.
            var existingTrips = [Trip]()
            if let trips = aggregatedTrips[trip.filterId] {
                existingTrips = trips
            }

            // Always add first trip.
            if existingTrips.isEmpty {
                aggregatedTrips[trip.filterId] = [trip]
                continue
            }

            // Don't add duplicates.
            if !existingTrips.filter({ $0.legs.first!.journeyId == trip.legs.first!.journeyId }).isEmpty {
                continue
            }

            // Add trip.
            existingTrips.append(trip)

            // Update aggregated trips.
            aggregatedTrips[trip.filterId] = existingTrips
        }

        aggregatedTrips = removeUnnecessaryTrips(from: aggregatedTrips)
        return sort(aggregatedTrips: aggregatedTrips).map { TripCellModel(trips: $0.1) }
    }

    private func sort(departures: [Departure]) -> [Departure] {
        return departures.sorted { $0.timeLeft < $1.timeLeft }
    }

    private func sort(trips: [Trip]) -> [Trip] {
        return trips.sorted { t1, t2 in
            let legs1 = t1.legs.first!
            let legs2 = t2.legs.first!

            if let commute = StopDataHandler.shared.currentCommute, !commute.isDeparture {
                return legs1.origin.timeLeft > legs2.origin.timeLeft
            } else {
                return legs1.origin.timeLeft < legs2.origin.timeLeft
            }
        }
    }

    // Returns array of tuples to preserve order.
    private func sort(aggregatedDepartures: [String: [Departure]]) -> [(String, [Departure])] {
        return aggregatedDepartures.sorted { t1, t2 in
            let departure1 = t1.value.first!
            let name1 = departure1.name
            let time1 = departure1.timeLeft

            let departure2 = t2.value.first!
            let name2 = departure2.name
            let time2 = departure2.timeLeft

            if let name1Int = Int(name1), let name2Int = Int(name2), name1Int != name2Int {
                return name1Int < name2Int // Sort on numerical name first.
            } else if name1 != name2 {
                return name1 < name2 // Sort on alphabetical name second.
            } else {
                return time1 < time2 // Sort on time last.
            }
        }
    }

    // Returns array of tuples to preserve order.
    private func sort(aggregatedTrips: [String: [Trip]]) -> [(String, [Trip])] {
        return aggregatedTrips.sorted { t1, t2 in
            let trip1 = t1.value.first!
            let name1 = trip1.legs.first!.name
            let time1 = trip1.legs.first!.origin.timeLeft

            let trip2 = t2.value.first!
            let name2 = trip2.legs.first!.name
            let time2 = trip2.legs.first!.origin.timeLeft

            if time1 != time2 {
                // Sort on time first.
                if let commute = StopDataHandler.shared.currentCommute, !commute.isDeparture {
                    return time1 > time2
                } else {
                    return time1 < time2
                }
            } else if let name1Int = Int(name1), let name2Int = Int(name2), name1Int != name2Int {
                return name1Int < name2Int // Sort on numerical name second.
            } else if name1 != name2 {
                return name1 < name2 // Sort on alphabetical name third.
            } else {
                return trip1.legs.count < trip2.legs.count // Sort on number of transfers last.
            }
        }
    }

    private func removeUnnecessaryTrips(from aggregatedTrips: [String: [Trip]]) -> [String: [Trip]] {
        if aggregatedTrips.isEmpty { return aggregatedTrips }

        var tripsWithoutTransfers = [String]()
        var tripsToAdd = [String]()
        var aggregatedTripsToReturn = [String: [Trip]]()

        for trips in aggregatedTrips.values {
            let trip = trips.first!
            if trip.legs.count != 1 { continue }

            let commonFilterId = trip.legs.first!.name + trip.legs.first!.direction + trip.legs.last!.destination.name
            tripsWithoutTransfers.append(commonFilterId)
        }

        for trips in aggregatedTrips.values {
            let trip = trips.first!
            let commonFilterId = trip.legs.first!.name + trip.legs.first!.direction + trip.legs.last!.destination.name

            // Don't add duplicates.
            if tripsToAdd.contains(commonFilterId) {
                continue
            }

            // Don't add trips with transfers that have counterparts without transfers.
            if tripsWithoutTransfers.contains(commonFilterId) && (trip.legs.count > 1) {
                continue
            }

            aggregatedTripsToReturn[trip.filterId] = trips
            tripsToAdd.append(commonFilterId)
        }

        return aggregatedTripsToReturn
    }
}
