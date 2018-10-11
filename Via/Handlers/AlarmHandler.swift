import UserNotifications

struct AlarmHandler {
    
    static let shared = AlarmHandler()

    private init() {}

    func setAlarm(for departure: Departure, at date: Date, minsInAdvance: Int) {
        let contentBody = "Linje \(departure.name) mot \(departure.direction) beräknas avgå om ca \(minsInAdvance) min."
        let triggerDate = Calendar.current.dateComponents(in: .current, from: date.inFuture(mins: minsInAdvance))

        setAlarm(id: departure.filterId, contentBody: contentBody, triggerDate: triggerDate)
    }

    func setAlarm(for trip: Trip, at date: Date, minsInAdvance: Int) {
        let contentBody = "Linje \(trip.legs.first!.name) mot \(trip.legs.first!.direction) beräknas avgå om ca \(minsInAdvance) min."
        let triggerDate = Calendar.current.dateComponents(in: .current, from: date.inFuture(mins: minsInAdvance))

        setAlarm(id: trip.filterId, contentBody: contentBody, triggerDate: triggerDate)
    }

    private func setAlarm(id: String, contentBody: String, triggerDate: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "Ett meddelande från Via"
        content.body = contentBody

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        _ = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
