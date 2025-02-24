import Foundation

enum FilterType: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted

    var translated: String {
        switch self {
        case .all:
            return "Все трекеры"
        case .today:
            return "Трекеры на сегодня"
        case .completed:
            return "Завершенные"
        case .notCompleted:
            return "Не завершенные"
        }
    }
}

struct Filters {
    let date: Date?
    let type: FilterType

    init(date: Date? = nil, type: FilterType? = .all) {
        self.date = date
        self.type = type ?? .all
    }
}
