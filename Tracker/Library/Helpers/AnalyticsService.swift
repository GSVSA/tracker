import Foundation
import AppMetricaCore

enum AnalyticsEventType: String {
    case open
    case close
    case click
}

enum AnalyticsItemType: String {
    case add_track
    case track
    case filter
    case edit
    case delete
}

struct AnalyticsServiceEvent {
    let event: AnalyticsEventType
    let screen: String
    let item: AnalyticsItemType?

    init(event: AnalyticsEventType, screen: String = "Main", item: AnalyticsItemType? = nil) {
        self.event = event
        self.screen = screen
        self.item = item
    }
}

final class AnalyticsService {
    private func report(name: String, _ event: AnalyticsServiceEvent) {
        var params: [String: String] = [
            "event": event.event.rawValue,
            "screen": event.screen,
        ]
        if event.event == .click, let item = event.item {
            params["item"] = item.rawValue
        }

        AppMetrica.reportEvent(name: name, parameters: params, onFailure: { error in
            print("DID FAIL REPORT EVENT: %@", name)
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    func report(_ event: AnalyticsServiceEvent) {
        report(name: event.event.rawValue, event)
    }

    func click(screen: String = "Main", item: AnalyticsItemType) {
        let event = AnalyticsServiceEvent(event: .click, screen: screen, item: item)
        report(event)
    }

    func open(screen: String = "Main") {
        let event = AnalyticsServiceEvent(event: .open, screen: screen)
        report(event)
    }

    func close(screen: String = "Main") {
        let event = AnalyticsServiceEvent(event: .close, screen: screen)
        report(event)
    }
}
