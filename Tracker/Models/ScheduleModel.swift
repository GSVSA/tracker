import Foundation

protocol ScheduleProtocol {
    var selectedDays: [String]? { get }
}

struct Schedule: ScheduleProtocol {
    let selectedDays: [String]?
}

